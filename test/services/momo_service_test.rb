# frozen_string_literal: true

require "test_helper"

class MomoServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:buyer)
    @cart = Cart.create!(user: @user)
    @product = products(:digital)
    
    # Add product to cart
    @cart.add_item(@product)
    
    # Create test payload
    @payload = {
      transaction_reference: "MOMO12345ABCDE",
      status: "successful",
      amount: 100,
      provider: "mtn"
    }.to_json
    
    @signature = "valid_signature"
    
    # Mock the WebhookSignatureVerifier
    @mock_verifier = mock('WebhookSignatureVerifier')
    WebhookSignatureVerifier.stubs(:new).returns(@mock_verifier)
  end
  
  test "initiate_payment validates phone number format" do
    service = MomoService.new(@user)
    
    # Test with valid phone number
    result = service.initiate_payment(@cart, "0241234567", "mtn")
    assert result[:success]
    
    # Test with invalid phone number
    result = service.initiate_payment(@cart, "invalid", "mtn")
    assert_not result[:success]
    assert_equal "Invalid phone number format", result[:error]
  end
  
  test "initiate_payment validates provider" do
    service = MomoService.new(@user)
    
    # Test with valid provider
    result = service.initiate_payment(@cart, "0241234567", "mtn")
    assert result[:success]
    
    # Test with invalid provider
    result = service.initiate_payment(@cart, "0241234567", "invalid")
    assert_not result[:success]
    assert_equal "Invalid mobile money provider", result[:error]
  end
  
  test "initiate_payment creates a pending order" do
    service = MomoService.new(@user)
    
    assert_difference -> { Order.count } do
      service.initiate_payment(@cart, "0241234567", "mtn")
    end
    
    order = Order.last
    assert_equal "pending", order.status
    assert_equal "pending", order.payment_status
    assert_equal "momo", order.payment_processor
    assert_not_nil order.payment_id
  end
  
  test "verify_payment updates order status on success" do
    # Create a pending order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345",
      payment_status: "pending",
      status: "pending",
      total_amount: 100
    )
    
    service = MomoService.new(@user)
    
    # Mock the random payment success
    service.stubs(:rand).returns(0)
    
    result = service.verify_payment("MOMO12345")
    
    assert result[:success]
    assert_equal "paid", result[:status]
    
    # Verify order was updated
    order.reload
    assert_equal "paid", order.status
    assert_equal "paid", order.payment_status
  end
  
  test "process_webhook validates signature" do
    # Mock the verifier to return false (invalid signature)
    @mock_verifier.stubs(:verify).returns(false)
    
    result = MomoService.process_webhook("mtn", @payload, @signature)
    
    assert_equal 403, result[:status]
    assert_equal "Invalid signature", result[:error]
    
    # Verify WebhookSignatureVerifier was constructed correctly
    WebhookSignatureVerifier.expects(:new).with(provider: "mtn", payload: @payload, signature: @signature).returns(@mock_verifier)
    MomoService.process_webhook("mtn", @payload, @signature)
  end
  
  test "process_webhook handles successful payments" do
    # Create a pending order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345ABCDE",
      payment_status: "pending",
      status: "pending",
      total_amount: 100,
      product: @product
    )
    
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Mock PaymentAuditLog creation
    PaymentAuditLog.stubs(:create!).returns(true)
    
    # Ensure the digital file is attached to the product
    @product.digital_file.attach(io: StringIO.new("test file content"), filename: "test.pdf", content_type: "application/pdf")
    
    # Process a successful payment webhook
    assert_difference -> { DownloadLink.count } do
      result = MomoService.process_webhook("mtn", @payload, @signature)
      assert_equal 200, result[:status]
    end
    
    # Verify order was updated
    order.reload
    assert_equal "paid", order.status
    assert_equal "paid", order.payment_status
    
    # Verify download link was created
    link = DownloadLink.last
    assert_equal @user.id, link.user_id
    assert_equal @product.id, link.product_id
    assert_equal order.id, link.order_id
  end
  
  test "process_webhook handles failed payments" do
    # Create a pending order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345ABCDE",
      payment_status: "pending",
      status: "pending",
      total_amount: 100
    )
    
    # Create payload with failed status
    failed_payload = {
      transaction_reference: "MOMO12345ABCDE",
      status: "failed",
      amount: 100,
      provider: "mtn"
    }.to_json
    
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Mock PaymentAuditLog creation
    PaymentAuditLog.stubs(:create!).returns(true)
    
    # Process a failed payment webhook
    result = MomoService.process_webhook("mtn", failed_payload, @signature)
    assert_equal 200, result[:status]
    
    # Verify order was updated
    order.reload
    assert_equal "failed", order.status
    assert_equal "failed", order.payment_status
  end
  
  test "process_webhook is idempotent" do
    # Create an already paid order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345ABCDE",
      payment_status: "paid",
      status: "paid",
      total_amount: 100
    )
    
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # No new download links should be created
    assert_no_difference -> { DownloadLink.count } do
      result = MomoService.process_webhook("mtn", @payload, @signature)
      assert_equal 200, result[:status]
    end
    
    # Verify order status remains the same
    order.reload
    assert_equal "paid", order.status
    assert_equal "paid", order.payment_status
  end
  
  test "process_webhook handles missing orders" do
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Process webhook for non-existent order
    result = MomoService.process_webhook("mtn", @payload, @signature)
    assert_equal 404, result[:status]
    assert_equal "Order not found", result[:error]
  end
  
  test "process_webhook handles invalid JSON" do
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Process webhook with invalid JSON
    result = MomoService.process_webhook("mtn", "invalid json", @signature)
    assert_equal 400, result[:status]
    assert_equal "Invalid payload", result[:error]
  end
  
  test "process_webhook handles database errors" do
    # Create a pending order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345ABCDE",
      payment_status: "pending",
      status: "pending",
      total_amount: 100
    )
    
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Mock a database error
    Order.any_instance.stubs(:update!).raises(ActiveRecord::RecordInvalid.new(order))
    
    # Process webhook should handle the exception
    result = MomoService.process_webhook("mtn", @payload, @signature)
    assert_equal 422, result[:status]
    assert_equal "Processing error", result[:error]
  end
  
  test "phone number validation is comprehensive" do
    service = MomoService.new(@user)
    
    # Valid MTN Ghana numbers
    assert service.send(:valid_phone_number?, "0241234567", "mtn")
    assert service.send(:valid_phone_number?, "054-123-4567", "mtn")
    assert service.send(:valid_phone_number?, "055 123 4567", "mtn")
    assert service.send(:valid_phone_number?, "0591234567", "mtn")
    
    # Valid Airtel Ghana numbers
    assert service.send(:valid_phone_number?, "0261234567", "airtel")
    assert service.send(:valid_phone_number?, "056-123-4567", "airtel")
    
    # Valid Vodafone Ghana numbers
    assert service.send(:valid_phone_number?, "0201234567", "vodafone")
    assert service.send(:valid_phone_number?, "050-123-4567", "vodafone")
    
    # Invalid numbers
    assert_not service.send(:valid_phone_number?, "024123", "mtn") # Too short
    assert_not service.send(:valid_phone_number?, "0301234567", "mtn") # Wrong prefix
    assert_not service.send(:valid_phone_number?, "1234567890", "mtn") # No prefix
    assert_not service.send(:valid_phone_number?, "abc1234567", "mtn") # Non-numeric
  end
  
  test "payment audit logs are created" do
    # Create a pending order
    order = Order.create!(
      user: @user,
      payment_processor: "momo",
      payment_id: "MOMO12345ABCDE",
      payment_status: "pending",
      status: "pending",
      total_amount: 100
    )
    
    # Mock a successful signature verification
    @mock_verifier.stubs(:verify).returns(true)
    
    # Should create a payment audit log
    assert_difference -> { PaymentAuditLog.count } do
      MomoService.process_webhook("mtn", @payload, @signature)
    end
    
    # Verify the log contents
    log = PaymentAuditLog.last
    assert_equal "payment_successful", log.event_type
    assert_equal "mtn", log.payment_processor
    assert_equal order.id, log.order_id
    assert_equal order.user_id, log.user_id
    assert_equal order.total_amount, log.amount
    assert_equal order.payment_id, log.transaction_id
  end
  
  test "transaction reference generation is unique" do
    service = MomoService.new(@user)
    
    # Generate a reference
    reference1 = service.send(:generate_transaction_reference)
    
    # Generate another reference
    reference2 = service.send(:generate_transaction_reference)
    
    # References should be unique
    assert_not_equal reference1, reference2
    
    # References should follow the pattern
    assert_match(/^MOMO\d+[A-F0-9]+$/, reference1)
    assert_match(/^MOMO\d+[A-F0-9]+$/, reference2)
  end
end
