# frozen_string_literal: true

require "test_helper"

class StripeServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:digital)
    @cart = @user.ensure_cart
    @cart.add_item(@product)

    @order = Order.create!(
      user: @user,
      total_amount: @product.price,
      status: "pending",
      payment_processor: "stripe",
      payment_id: "test_session_id",
      payment_status: "pending"
    )

    # Mock Stripe objects
    @mock_stripe_session = Struct.new(:id, :url, :payment_status).new(
      "test_session_id",
      "https://stripe.com/checkout/test",
      "paid"
    )

    @stripe_service = StripeService.new(@user)
  end

  test "should create checkout session with correct parameters" do
    # Mock Stripe API call
    Stripe::Checkout::Session.stub(:create, @mock_stripe_session) do
      session = @stripe_service.create_checkout_session(@cart)

      assert_equal @mock_stripe_session.id, session.id
      assert_equal @mock_stripe_session.url, session.url
    end
  end

  test "should retrieve checkout session" do
    # Mock Stripe API call
    Stripe::Checkout::Session.stub(:retrieve, @mock_stripe_session) do
      session = @stripe_service.retrieve_checkout_session("test_session_id")

      assert_equal @mock_stripe_session.id, session.id
      assert_equal @mock_stripe_session.payment_status, session.payment_status
    end
  end

  test "webhook should handle checkout.session.completed event" do
    # Create mock event
    event = Struct.new(:type, :data).new(
      "checkout.session.completed",
      Struct.new(:object).new(@mock_stripe_session)
    )

    # Process the event
    StripeService.handle_checkout_completed(event)

    # Verify order was updated
    @order.reload
    assert_equal "paid", @order.status
    assert_equal "paid", @order.payment_status
  end

  test "webhook should create download link for digital products" do
    # Attach a mock digital file to the product
    @product.stub(:digital_file, OpenStruct.new(
      attached?: true,
      filename: OpenStruct.new(to_s: "test.pdf"),
      byte_size: 1024,
      content_type: "application/pdf"
    )) do
      # Create mock event
      event = Struct.new(:type, :data).new(
        "checkout.session.completed",
        Struct.new(:object).new(@mock_stripe_session)
      )

      # Count download links before
      download_links_count = DownloadLink.where(user: @user, product: @product).count

      # Process the event
      StripeService.handle_checkout_completed(event)

      # Verify a download link was created
      assert_equal download_links_count + 1, DownloadLink.where(user: @user, product: @product).count

      # Get the created download link
      download_link = DownloadLink.where(user: @user, product: @product).last

      # Verify download link properties
      assert_equal @user.id, download_link.user_id
      assert_equal @product.id, download_link.product_id
      assert_equal @order.id, download_link.order_id
      assert_equal "test.pdf", download_link.file_name
      assert_equal 1024, download_link.file_size
      assert_equal "application/pdf", download_link.content_type
      assert download_link.active?
      assert_equal 0, download_link.download_count
      assert_equal 5, download_link.download_limit
    end
  end

  test "webhook signature verification should reject invalid signatures" do
    # Mock invalid signature
    result = StripeService.handle_webhook("{}", "invalid_signature")

    assert_equal 403, result[:status]
    assert_equal "Invalid signature", result[:error]
  end
end
