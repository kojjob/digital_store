# frozen_string_literal: true

require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:digital)
    sign_in @user

    # Ensure user has a cart with items
    @cart = @user.ensure_cart
    @cart.add_item(@product)

    # Create order for testing specific order endpoints
    @order = Order.create!(
      user: @user,
      total_amount: @product.price,
      status: "pending",
      payment_processor: "stripe",
      payment_id: "test_session_id",
      payment_status: "pending"
    )

    # Mock Stripe session for testing
    @mock_stripe_session = Struct.new(:id, :url, :payment_status).new(
      "test_session_id",
      "https://stripe.com/checkout/test",
      "paid"
    )
  end

  test "should redirect to login if not authenticated" do
    sign_out @user
    post create_payment_path, params: { payment_method: "stripe" }
    assert_redirected_to new_user_session_path
  end

  test "should redirect to checkout when invalid payment method" do
    post create_payment_path, params: { payment_method: "invalid" }
    assert_redirected_to new_checkout_path
    assert_equal "Please select a valid payment method", flash[:alert]
  end

  test "should create stripe checkout session" do
    # Mock StripeService
    StripeService.stub_any_instance(:create_checkout_session, @mock_stripe_session) do
      post create_payment_path, params: { payment_method: "stripe" }

      # Check that we redirect to Stripe URL
      assert_redirected_to @mock_stripe_session.url

      # Verify session was set
      assert_equal @mock_stripe_session.id, session[:checkout_session_id]
      assert_not_nil session[:pending_order_id]
    end
  end

  test "should handle stripe success with valid session" do
    # Set up session variables
    get stripe_success_path, session: {
      checkout_session_id: @order.payment_id,
      pending_order_id: @order.id
    }

    # Mock Stripe session retrieval
    StripeService.stub_any_instance(:retrieve_checkout_session, @mock_stripe_session) do
      # Process the success callback
      get stripe_success_path

      # Check redirect to order page
      assert_redirected_to order_path(@order)

      # Check flash message
      assert_equal "Payment successful! Your order has been placed.", flash[:notice]

      # Reload order and check status
      @order.reload
      assert_equal "paid", @order.status
      assert_equal "paid", @order.payment_status
    end
  end

  test "should handle stripe cancel" do
    # Set up session variables
    get stripe_cancel_path, session: {
      checkout_session_id: @order.payment_id,
      pending_order_id: @order.id
    }

    # Check redirect to cart page
    assert_redirected_to cart_path

    # Check flash message
    assert_equal "Payment was cancelled. Your cart is still saved.", flash[:alert]

    # Reload order and check status
    @order.reload
    assert_equal "cancelled", @order.status
    assert_equal "cancelled", @order.payment_status
  end

  test "should handle mobile money payment initiation" do
    # Mock MomoService
    momo_result = {
      success: true,
      transaction_ref: "MOMO123456789",
      order_id: @order.id,
      message: "Payment request sent"
    }

    MomoService.stub_any_instance(:initiate_payment, momo_result) do
      post momo_payment_path, params: {
        provider: "mtn",
        phone_number: "0241234567"
      }

      # Check redirect to verification page
      assert_redirected_to momo_verify_path(momo_result[:transaction_ref])

      # Verify session was set
      assert_equal momo_result[:transaction_ref], session[:momo_transaction_ref]
      assert_equal momo_result[:order_id], session[:pending_order_id]
    end
  end

  test "should handle mobile money verification" do
    # Set up session variables
    transaction_ref = "MOMO123456789"

    # Mock MomoService verification
    momo_result = {
      success: true,
      status: "paid",
      order_id: @order.id,
      message: "Payment completed successfully"
    }

    get momo_verify_path(transaction_ref), session: {
      momo_transaction_ref: transaction_ref,
      pending_order_id: @order.id
    }

    MomoService.stub_any_instance(:verify_payment, momo_result) do
      # Process the verification
      get momo_verify_path(transaction_ref)

      # Check redirect to order page
      assert_redirected_to order_path(@order)

      # Check flash message
      assert_equal "Payment successful! Your order has been placed.", flash[:notice]

      # Check session was cleared
      assert_nil session[:momo_transaction_ref]
      assert_nil session[:pending_order_id]
    end
  end
end
