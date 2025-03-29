# frozen_string_literal: true

require "test_helper"

class MomoWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload = {
      transaction_reference: "MOMO12345ABCDE",
      status: "successful",
      amount: 100,
      provider: "mtn"
    }.to_json
    
    @signature = "valid_signature"
    
    # Mock the MomoService
    MomoService.stubs(:process_webhook).returns({ status: 200 })
    
    # Set up test IP allowlist configuration
    @allowed_ips = ['127.0.0.1', '::1', '192.168.1.1']
    Rails.application.config.stubs(:webhooks).returns(
      ActiveSupport::OrderedOptions.new.tap do |config|
        config.momo = { allowed_ips: @allowed_ips }
      end
    )
  end
  
  test "should reject requests without signature header" do
    post momo_webhook_url('mtn')
    
    assert_response :bad_request
    assert_equal({ "status" => "error", "error" => "Signature header missing" }, JSON.parse(response.body))
  end
  
  test "should reject requests for invalid providers" do
    post momo_webhook_url('invalid'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature }
    
    assert_response :bad_request
    assert_equal({ "status" => "error", "error" => "Invalid provider" }, JSON.parse(response.body))
  end
  
  test "should process valid webhook requests" do
    # Expectations
    MomoService.expects(:process_webhook).with('mtn', @payload, @signature).returns({ status: 200 })
    PaymentAuditLog.stubs(:create).returns(true)
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :success
    assert_equal({ "status" => "success" }, JSON.parse(response.body))
  end
  
  test "should reject requests from disallowed IPs" do
    # Configure test to use a specific IP
    Rails.application.config.stubs(:webhooks).returns(
      ActiveSupport::OrderedOptions.new.tap do |config|
        config.momo = { allowed_ips: ['192.168.1.1'] } # Not matching the test IP
      end
    )
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'REMOTE_ADDR' => '10.0.0.1' }
    
    assert_response :forbidden
    assert_equal({ "status" => "error", "error" => "Unauthorized source" }, JSON.parse(response.body))
  end
  
  test "should allow requests from allowed IPs" do
    # Configure test to use a specific IP
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('192.168.1.1')
    
    # Expectations
    MomoService.expects(:process_webhook).returns({ status: 200 })
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :success
  end
  
  test "should handle webhook processing errors" do
    # Mock MomoService to return an error
    MomoService.stubs(:process_webhook).returns({ status: 400, error: "Test error" })
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :bad_request
    assert_equal({ "status" => "error" }, JSON.parse(response.body))
  end
  
  test "should not expose detailed error messages in responses" do
    # Mock MomoService to return a detailed error
    MomoService.stubs(:process_webhook).returns({ status: 500, error: "Detailed internal server error" })
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :internal_server_error
    
    # Verify detailed error is not exposed
    assert_equal({ "status" => "error" }, JSON.parse(response.body))
  end
  
  test "should handle unexpected exceptions" do
    # Mock MomoService to raise an exception
    MomoService.stubs(:process_webhook).raises(StandardError.new("Unexpected error"))
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :internal_server_error
    assert_equal({ "status" => "error" }, JSON.parse(response.body))
  end
  
  test "should create audit log for received webhooks" do
    # Mock finding an order
    Order.stubs(:find_by).returns(Order.new(id: 1, user_id: 1, total_amount: 100))
    
    # Should create a webhook audit log
    PaymentAuditLog.expects(:create).with(
      has_entries(
        event_type: "webhook_received",
        payment_processor: "mtn"
      )
    ).returns(true)
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :success
  end
  
  test "should handle missing orders in audit log gracefully" do
    # Order not found
    Order.stubs(:find_by).returns(nil)
    
    # Should still process the webhook
    MomoService.expects(:process_webhook).returns({ status: 200 })
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :success
  end
  
  test "should not fail webhook processing if audit logging fails" do
    # Audit log creation fails
    PaymentAuditLog.stubs(:create).raises(StandardError.new("Audit log error"))
    
    # Should still process the webhook
    MomoService.expects(:process_webhook).returns({ status: 200 })
    
    post momo_webhook_url('mtn'), 
         params: @payload, 
         headers: { 'X-Momo-Signature' => @signature, 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :success
  end
end
