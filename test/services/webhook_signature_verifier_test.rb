# frozen_string_literal: true

require "test_helper"

class WebhookSignatureVerifierTest < ActiveSupport::TestCase
  setup do
    @payload = '{"transaction_reference":"MOMO12345ABCDE","status":"successful","amount":100,"provider":"mtn"}'
    @timestamp = Time.current.to_i.to_s
    @stripe_payload = '{"id":"evt_123","type":"payment_intent.succeeded"}'
    
    # Set up test secrets
    ENV["MOMO_MTN_WEBHOOK_SECRET"] = "test_mtn_secret"
    ENV["MOMO_AIRTEL_WEBHOOK_SECRET"] = "test_airtel_secret"
    ENV["MOMO_VODAFONE_WEBHOOK_SECRET"] = "test_vodafone_secret"
    
    # Mock Rails credentials for Stripe
    Rails.application.credentials.stubs(:dig).with(:stripe, :webhook_secret).returns("test_stripe_secret")
    Rails.application.credentials.stubs(:dig).with(:paypal, :webhook_secret).returns("test_paypal_secret")
  end

  teardown do
    # Clean up environment variables after tests
    ENV.delete("MOMO_MTN_WEBHOOK_SECRET")
    ENV.delete("MOMO_AIRTEL_WEBHOOK_SECRET")
    ENV.delete("MOMO_VODAFONE_WEBHOOK_SECRET")
  end

  test "verify returns false when signature is blank" do
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: nil)
    assert_not verifier.verify
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: "")
    assert_not verifier.verify
  end

  test "verify returns false when payload is blank" do
    signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: nil, signature: signature)
    assert_not verifier.verify
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: "", signature: signature)
    assert_not verifier.verify
  end

  test "verify returns false for unsupported provider" do
    signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    verifier = WebhookSignatureVerifier.new(provider: "unknown", payload: @payload, signature: signature)
    assert_not verifier.verify
  end

  test "verify returns false when secret is not configured" do
    ENV.delete("MOMO_MTN_WEBHOOK_SECRET")
    signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: signature)
    assert_not verifier.verify
  end

  test "verify returns true for valid MoMo signature" do
    # Generate a valid HMAC signature
    valid_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: valid_signature)
    assert verifier.verify
  end

  test "verify returns false for invalid MoMo signature" do
    # Generate an invalid signature with wrong secret
    invalid_signature = OpenSSL::HMAC.hexdigest("SHA256", "wrong_secret", @payload)
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: invalid_signature)
    assert_not verifier.verify
  end

  test "verify handles different MoMo providers correctly" do
    # Test for Airtel
    airtel_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_airtel_secret", @payload)
    airtel_verifier = WebhookSignatureVerifier.new(provider: "airtel", payload: @payload, signature: airtel_signature)
    assert airtel_verifier.verify
    
    # Test for Vodafone
    vodafone_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_vodafone_secret", @payload)
    vodafone_verifier = WebhookSignatureVerifier.new(provider: "vodafone", payload: @payload, signature: vodafone_signature)
    assert vodafone_verifier.verify
  end

  test "verify handles exceptions gracefully" do
    # Test with nil payload to trigger an exception in HMAC calculation
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: nil, signature: "some_signature")
    assert_not verifier.verify
    
    # Test with missing provider to trigger case statement error
    verifier = WebhookSignatureVerifier.new(provider: nil, payload: @payload, signature: "some_signature")
    assert_not verifier.verify
  end

  test "verify is secure against timing attacks" do
    # Generate a valid signature
    valid_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    
    # Mock the secure_compare method to verify it's called
    ActiveSupport::SecurityUtils.expects(:secure_compare).once.returns(true)
    
    verifier = WebhookSignatureVerifier.new(provider: "mtn", payload: @payload, signature: valid_signature)
    verifier.verify
  end

  test "verify handles Stripe signatures correctly" do
    # Prepare Stripe signature
    signed_payload = "#{@timestamp}.#{@stripe_payload}"
    computed_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_stripe_secret", signed_payload)
    stripe_signature = "t=#{@timestamp},v1=#{computed_signature}"
    
    verifier = WebhookSignatureVerifier.new(
      provider: "stripe", 
      payload: @stripe_payload, 
      signature: stripe_signature,
      timestamp: @timestamp
    )
    
    assert verifier.verify
  end

  test "verify returns false for invalid Stripe signatures" do
    # Prepare invalid Stripe signature (wrong secret)
    signed_payload = "#{@timestamp}.#{@stripe_payload}"
    computed_signature = OpenSSL::HMAC.hexdigest("SHA256", "wrong_secret", signed_payload)
    stripe_signature = "t=#{@timestamp},v1=#{computed_signature}"
    
    verifier = WebhookSignatureVerifier.new(
      provider: "stripe", 
      payload: @stripe_payload, 
      signature: stripe_signature,
      timestamp: @timestamp
    )
    
    assert_not verifier.verify
  end

  test "verify returns false for Stripe when timestamp is missing" do
    # Prepare Stripe signature without timestamp
    signed_payload = "#{@timestamp}.#{@stripe_payload}"
    computed_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_stripe_secret", signed_payload)
    stripe_signature = "v1=#{computed_signature}"
    
    verifier = WebhookSignatureVerifier.new(
      provider: "stripe", 
      payload: @stripe_payload, 
      signature: stripe_signature
    )
    
    assert_not verifier.verify
  end

  test "verify correctly parses complex Stripe signatures" do
    # Stripe can send multiple signatures
    signed_payload = "#{@timestamp}.#{@stripe_payload}"
    computed_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_stripe_secret", signed_payload)
    alternate_signature = OpenSSL::HMAC.hexdigest("SHA256", "old_secret", signed_payload)
    
    # Complex signature with multiple parts
    stripe_signature = "t=#{@timestamp},v1=#{computed_signature},v1=#{alternate_signature},v0=invalid"
    
    verifier = WebhookSignatureVerifier.new(
      provider: "stripe", 
      payload: @stripe_payload, 
      signature: stripe_signature,
      timestamp: @timestamp
    )
    
    assert verifier.verify
  end

  test "verify sanitizes and normalizes provider names" do
    # Generate a valid signature
    valid_signature = OpenSSL::HMAC.hexdigest("SHA256", "test_mtn_secret", @payload)
    
    # Test with capitalized provider name
    verifier = WebhookSignatureVerifier.new(provider: "MTN", payload: @payload, signature: valid_signature)
    assert verifier.verify
    
    # Test with whitespace
    verifier = WebhookSignatureVerifier.new(provider: " mtn ", payload: @payload, signature: valid_signature)
    assert verifier.verify
  end
end
