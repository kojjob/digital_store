# frozen_string_literal: true

# Common concern for webhook handling across payment providers
module WebhookHandling
  extend ActiveSupport::Concern

  included do
    # Skip CSRF protection for webhooks - providers use signature verification instead
    skip_before_action :verify_authenticity_token
    # Skip authentication for webhook endpoints
    skip_before_action :authenticate_user!
    # Add IP allowlist check
    before_action :verify_webhook_source
  end

  private

  # Verify the webhook request is coming from an allowed IP address
  def verify_webhook_source
    provider = webhook_provider
    allowed_ips = allowed_webhook_ips(provider)

    # Skip the check if no IPs are configured (development mode)
    return true if allowed_ips.blank?

    unless allowed_ips.include?(request.remote_ip)
      Rails.logger.error("SECURITY WARNING: #{provider.upcase} webhook called from unauthorized IP: #{request.remote_ip}")
      render json: { status: "error", error: "Unauthorized source" }, status: :forbidden
      return false
    end

    true
  end

  # Get the list of allowed webhook IPs for the specified provider
  def allowed_webhook_ips(provider)
    # Get the list from configuration, with a different list per environment
    config_ips = Rails.application.config_for(:webhooks).dig(provider.to_sym, :allowed_ips)
    
    # Convert to an array if a string was provided
    return config_ips.split(',').map(&:strip) if config_ips.is_a?(String)
    
    # Return as is if it's already an array
    return config_ips if config_ips.is_a?(Array)
    
    # Fall back to environment variables if config is missing
    env_ips = ENV.fetch("#{provider.upcase}_WEBHOOK_ALLOWED_IPS", nil)
    return env_ips.split(',').map(&:strip) if env_ips.present?
    
    # Return an empty array if no configuration is found
    []
  end

  # Log a webhook error and respond with an error
  def log_and_respond(error_message, status)
    Rails.logger.error("#{webhook_provider.upcase} webhook error: #{error_message}")
    render json: { status: "error", error: error_message }, status: status
  end

  # Create an audit log entry for the webhook
  def create_webhook_audit_log(provider, payload, transaction_ref = nil, order = nil)
    begin
      # Extract transaction reference from payload if not provided
      transaction_ref ||= extract_transaction_ref_from_payload(payload, provider)
      
      # Find the order associated with this transaction if not provided
      order ||= find_order_for_transaction(transaction_ref, provider)
      
      if order
        PaymentAuditLog.create(
          user_id: order.user_id,
          order_id: order.id,
          event_type: "webhook_received",
          payment_processor: provider,
          amount: order.total_amount,
          transaction_id: transaction_ref,
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          metadata: {
            headers: sanitize_headers(request.headers),
            timestamp: Time.current,
            webhook_id: request.request_id
          }.to_json
        )
      else
        # Create a placeholder log without user/order if order not found
        Rails.logger.warn("#{provider.upcase} webhook received for unknown transaction: #{transaction_ref}")
      end
    rescue => e
      # Don't fail webhook processing if audit logging fails
      Rails.logger.error("Failed to create webhook audit log: #{e.message}")
    end
  end

  # Extract transaction reference from payload based on provider
  def extract_transaction_ref_from_payload(payload, provider)
    begin
      data = JSON.parse(payload)
      
      case provider
      when "momo"
        data["transaction_reference"]
      when "stripe"
        data.dig("data", "object", "id")
      else
        nil
      end
    rescue
      nil
    end
  end

  # Find order associated with transaction reference
  def find_order_for_transaction(transaction_ref, provider)
    return nil if transaction_ref.blank?
    
    Order.find_by(payment_id: transaction_ref, payment_processor: provider)
  end

  # Sanitize headers to remove sensitive information
  def sanitize_headers(headers)
    safe_headers = {}
    
    # Only include specific headers we care about
    %w[
      HTTP_USER_AGENT
      HTTP_ACCEPT
      REMOTE_ADDR
      REQUEST_METHOD
      SERVER_NAME
    ].each do |key|
      safe_headers[key] = headers[key] if headers[key].present?
    end
    
    # Include provider-specific signature headers
    provider_header = webhook_signature_header
    safe_headers[provider_header] = headers[provider_header] if headers[provider_header].present?
    
    safe_headers
  end

  # Abstract methods to be implemented by subclasses
  def webhook_provider
    raise NotImplementedError, "Subclasses must implement webhook_provider"
  end

  def webhook_signature_header
    raise NotImplementedError, "Subclasses must implement webhook_signature_header"
  end
end
