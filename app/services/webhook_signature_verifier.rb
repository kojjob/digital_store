# frozen_string_literal: true

# Service class for verifying webhook signatures from different payment providers
class WebhookSignatureVerifier
  # Initialize with provider, payload, and signature
  def initialize(provider:, payload:, signature:, timestamp: nil, headers: {})
    @provider = provider.to_s.downcase
    @payload = payload
    @signature = signature
    @timestamp = timestamp
    @headers = headers
  end

  # Verify the signature based on the provider
  def verify
    return false if @signature.blank? || @payload.blank?

    case @provider
    when "mtn", "airtel", "vodafone"
      verify_momo_signature
    when "stripe"
      verify_stripe_signature
    when "paypal"
      verify_paypal_signature
    else
      Rails.logger.error("Unsupported webhook provider: #{@provider}")
      false
    end
  rescue => e
    Rails.logger.error("Error verifying webhook signature: #{e.class.name} - #{e.message}")
    false
  end

  private

  # Verify MoMo signature using HMAC-SHA256
  def verify_momo_signature
    return false if @signature.blank?

    # Get the provider's webhook secret from centralized configuration
    secret_key = PaymentConfig::MoMo.webhook_secret(@provider)
    return false if secret_key.blank?

    begin
      # Calculate expected signature
      expected_signature = OpenSSL::HMAC.hexdigest("SHA256", secret_key, @payload)

      # Use constant-time comparison to prevent timing attacks
      ActiveSupport::SecurityUtils.secure_compare(expected_signature, @signature)
    rescue => e
      Rails.logger.error("Error calculating MoMo signature: #{e.message}")
      false
    end
  end

  # Verify Stripe signature
  def verify_stripe_signature
    return false if @signature.blank? || @timestamp.blank?

    # Get Stripe webhook secret from centralized configuration
    secret_key = PaymentConfig::Stripe.webhook_secret
    return false if secret_key.blank?

    begin
      # Reconstruct the signed payload string
      signed_payload = "#{@timestamp}.#{@payload}"

      # Generate the expected signature
      expected_signature = OpenSSL::HMAC.hexdigest("SHA256", secret_key, signed_payload)

      # Extract the signature from the Stripe-Signature header
      stripe_signatures = parse_stripe_signature(@signature)

      # Look for a matching signature
      stripe_signatures.any? do |sig|
        ActiveSupport::SecurityUtils.secure_compare(expected_signature, sig)
      end
    rescue => e
      Rails.logger.error("Error calculating Stripe signature: #{e.message}")
      false
    end
  end

  # Verify PayPal signature (using PayPal's algorithm)
  def verify_paypal_signature
    return false if @signature.blank? || @headers["paypal-auth-algo"].blank?

    # Get PayPal webhook secret from centralized configuration
    secret_key = PaymentConfig.get_secret("paypal", "webhook_secret", "PAYPAL_WEBHOOK_SECRET")
    return false if secret_key.blank?

    begin
      # Implementation would depend on PayPal's specific verification method
      # This is a placeholder for the actual implementation
      Rails.logger.info("PayPal signature verification not fully implemented")
      false
    rescue => e
      Rails.logger.error("Error calculating PayPal signature: #{e.message}")
      false
    end
  end

  # Parse Stripe signature header into individual signatures
  def parse_stripe_signature(signature_header)
    signatures = []
    signature_header.split(",").each do |entry|
      entry_parts = entry.split("=")
      if entry_parts.length == 2 && entry_parts[0].strip == "v1"
        signatures << entry_parts[1].strip
      end
    end
    signatures
  end
end
