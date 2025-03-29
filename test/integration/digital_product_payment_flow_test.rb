# frozen_string_literal: true

require "test_helper"

class DigitalProductPaymentFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @digital_product = products(:digital)
    sign_in @user

    # Clear the cart first
    @cart = @user.ensure_cart
    @cart.clear

    # Mock for StripeService
    @mock_stripe_session = Struct.new(:id, :url, :payment_status).new(
      "test_session_id",
      "https://stripe.com/checkout/test",
      "paid"
    )
  end

  test "complete digital product purchase flow with stripe" do
    # Step 1: Add the product to cart
    post add_to_cart_path, params: { product_id: @digital_product.id, quantity: 1 }
    assert_redirected_to @digital_product

    # Step 2: View the cart
    get cart_path
    assert_response :success
    assert_select "h1", /Shopping Cart/

    # Make sure the product is in the cart
    assert_select ".cart-item", { count: 1 }
    assert_select ".cart-item-title", @digital_product.name

    # Step 3: Go to checkout
    get checkout_path
    assert_response :success
    assert_select "h1", /Checkout/

    # Step 4: Select Stripe payment method and submit
    StripeService.stub_any_instance(:create_checkout_session, @mock_stripe_session) do
      post create_payment_path, params: { payment_method: "stripe" }
      assert_redirected_to @mock_stripe_session.url
    end

    # Step 5: Simulate Stripe callback (success)
    order = Order.find_by(payment_id: @mock_stripe_session.id)
    assert_not_nil order

    StripeService.stub_any_instance(:retrieve_checkout_session, @mock_stripe_session) do
      get stripe_success_path, params: {},
        headers: {},
        env: {
          "rack.session" => {
            checkout_session_id: @mock_stripe_session.id,
            pending_order_id: order.id
          }
        }

      assert_redirected_to order_path(order)
    end

    # Step 6: Check the order page
    get order_path(order)
    assert_response :success
    assert_select "h1", /Order ##{order.id}/

    # Step 7: Check that a download link was created
    get downloads_path
    assert_response :success
    assert_select ".download-item", { minimum: 1 }

    # Get the download link
    download_link = DownloadLink.find_by(order: order)
    assert_not_nil download_link

    # Step 8: Try to download the file (mock attachment)
    @digital_product.stub(:digital_file, OpenStruct.new(attached?: true)) do
      get download_path(download_link.token)
      assert_response :redirect  # Should redirect to the file
    end

    # Step 9: Verify download count increased
    download_link.reload
    assert_equal 1, download_link.download_count
  end

  test "complete digital product purchase flow with mobile money" do
    # Step 1: Add the product to cart
    post add_to_cart_path, params: { product_id: @digital_product.id, quantity: 1 }
    assert_redirected_to @digital_product

    # Step 2: View the cart
    get cart_path
    assert_response :success

    # Step 3: Go to checkout
    get checkout_path
    assert_response :success

    # Step 4: Select Mobile Money payment method and submit
    post create_payment_path, params: { payment_method: "momo" }
    assert_response :success
    assert_select "h1", /Mobile Money Payment/

    # Step 5: Submit MoMo details
    transaction_ref = "MOMO#{Time.current.to_i}TEST"
    result = {
      success: true,
      transaction_ref: transaction_ref,
      order_id: 1,
      message: "Payment request sent"
    }

    MomoService.stub_any_instance(:initiate_payment, result) do
      post momo_payment_path, params: {
        provider: "mtn",
        phone_number: "0241234567"
      }

      assert_redirected_to momo_verify_path(transaction_ref)
    end

    # Step 6: Simulate verification success
    momo_result = {
      success: true,
      status: "paid",
      order_id: 1,
      message: "Payment completed successfully"
    }

    order = Order.find(result[:order_id])

    MomoService.stub_any_instance(:verify_payment, momo_result) do
      get momo_verify_path(transaction_ref), params: {},
        headers: {},
        env: {
          "rack.session" => {
            momo_transaction_ref: transaction_ref,
            pending_order_id: order.id
          }
        }

      assert_redirected_to order_path(order)
    end

    # Step 7: Check the order page
    get order_path(order)
    assert_response :success

    # Update order status to paid for testing
    order.update(status: "paid", payment_status: "paid")

    # Create download link manually (would be done by webhook)
    DownloadLink.create!(
      user: @user,
      product: @digital_product,
      order: order,
      expires_at: 7.days.from_now,
      download_limit: 5,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )

    # Step 8: Check downloads page
    get downloads_path
    assert_response :success
    assert_select ".download-item", { minimum: 1 }
  end
end
