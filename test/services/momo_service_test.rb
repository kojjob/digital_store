# frozen_string_literal: true

require "test_helper"

class MomoServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:digital)
    @cart = @user.ensure_cart
    @cart.add_item(@product)

    @order = Order.create!(
      user: @user,
      total_amount: @product.price,
      status: "pending",
      payment_processor: "momo",
      payment_id: "MOMO123456789",
      payment_status: "pending"
    )

    @momo_service = MomoService.new(@user)
  end

  test "should validate phone number format" do
    # Test valid phone numbers for different providers
    assert @momo_service.send(:valid_phone_number?, "0241234567", "mtn")
    assert @momo_service.send(:valid_phone_number?, "0261234567", "airtel")
    assert @momo_service.send(:valid_phone_number?, "0201234567", "vodafone")

    # Test invalid phone numbers
    assert_not @momo_service.send(:valid_phone_number?, "12345", "mtn")
    assert_not @momo_service.send(:valid_phone_number?, "", "airtel")
    assert_not @momo_service.send(:valid_phone_number?, nil, "vodafone")
    assert_not @momo_service.send(:valid_phone_number?, "0241234567", "invalid")
  end

  test "should reject invalid providers" do
    result = @momo_service.initiate_payment(@cart, "0241234567", "invalid")

    assert_not result[:success]
    assert_equal "Invalid mobile money provider", result[:error]
  end

  test "should reject invalid phone numbers" do
    result = @momo_service.initiate_payment(@cart, "123", "mtn")

    assert_not result[:success]
    assert_equal "Invalid phone number format", result[:error]
  end

  test "should initiate payment with valid parameters" do
    result = @momo_service.initiate_payment(@cart, "0241234567", "mtn")

    assert result[:success]
    assert_not_nil result[:transaction_ref]
    assert_not_nil result[:order_id]

    # Check that an order was created
    order = Order.find(result[:order_id])
    assert_equal "momo", order.payment_processor
    assert_equal "pending", order.status
    assert_equal "pending", order.payment_status

    # Check that payment details were saved
    payment_details = JSON.parse(order.payment_details)
    assert_equal "0241234567", payment_details["phone_number"]
    assert_equal "mtn", payment_details["provider"]
  end

  test "should verify payment status" do
    # Test with invalid transaction reference
    result = @momo_service.verify_payment("invalid_ref")
    assert_not result[:success]
    assert_equal "Invalid transaction reference", result[:error]

    # Test with valid transaction reference
    result = @momo_service.verify_payment(@order.payment_id)

    # The result could be success or not since it's randomized
    # We can't reliably test the specific result, but we can test the format
    if result[:success]
      assert_equal "paid", result[:status]
      assert_equal @order.id, result[:order_id]

      # Check order was updated
      @order.reload
      assert_equal "paid", @order.status
      assert_equal "paid", @order.payment_status
    else
      assert_equal "pending", result[:status]
      assert_equal @order.id, result[:order_id]
    end
  end

  test "webhook should handle successful payment" do
    # Attach a mock digital file to the product
    @product.stub(:digital_file, OpenStruct.new(
      attached?: true,
      filename: OpenStruct.new(to_s: "test.pdf"),
      byte_size: 1024,
      content_type: "application/pdf"
    )) do
      # Create webhook payload
      payload = {
        transaction_reference: @order.payment_id,
        status: "successful",
        provider: "mtn",
        phone_number: "0241234567",
        amount: @order.total_amount
      }.to_json
      signature = "test_signature"

      # Mock signature verification
      MomoService.stub(:valid_webhook_signature?, true) do
        # Process the webhook
        result = MomoService.process_webhook("mtn", payload, signature)

        assert_equal 200, result[:status]

        # Verify order was updated
        @order.reload
        assert_equal "paid", @order.status
        assert_equal "paid", @order.payment_status

        # Verify download link was created
        download_link = DownloadLink.find_by(order: @order)
        assert_not_nil download_link
      end
    end
  end

  test "webhook should handle failed payment" do
    # Create webhook payload for failed payment
    payload = {
      transaction_reference: @order.payment_id,
      status: "failed",
      provider: "mtn",
      phone_number: "0241234567",
      amount: @order.total_amount
    }.to_json
    signature = "test_signature"

    # Mock signature verification
    MomoService.stub(:valid_webhook_signature?, true) do
      # Process the webhook
      result = MomoService.process_webhook("mtn", payload, signature)

      assert_equal 200, result[:status]

      # Verify order was updated
      @order.reload
      assert_equal "failed", @order.status
      assert_equal "failed", @order.payment_status
    end
  end

  test "webhook should reject invalid signatures" do
    payload = {}.to_json
    signature = "invalid_signature"

    # Skip signature verification
    MomoService.stub(:valid_webhook_signature?, false) do
      result = MomoService.process_webhook("mtn", payload, signature)

      assert_equal 403, result[:status]
      assert_equal "Invalid signature", result[:error]
    end
  end
end
