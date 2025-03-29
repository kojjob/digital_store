# frozen_string_literal: true

require "test_helper"

module Admin
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = users(:one)
      @admin.update(admin: true)
      sign_in @admin

      @product = products(:digital)
      @user = users(:two)

      # Create test orders
      @paid_order = Order.create!(
        user: @user,
        product: @product,
        total_amount: 19.99,
        status: "paid",
        payment_processor: "stripe",
        payment_id: "test_payment_paid",
        payment_status: "paid"
      )

      @pending_order = Order.create!(
        user: @user,
        product: @product,
        total_amount: 29.99,
        status: "pending",
        payment_processor: "momo",
        payment_id: "test_payment_pending",
        payment_status: "pending"
      )
    end

    test "should redirect non-admin users" do
      regular_user = users(:two)
      sign_in regular_user

      get admin_payments_path
      assert_redirected_to root_path
      assert_equal "You must be an administrator to access this area.", flash[:alert]
    end

    test "should get index" do
      get admin_payments_path
      assert_response :success

      # Verify that the index shows the expected content
      assert_select "h1", "Payment Management"

      # Check that our test orders are in the table
      assert_select "td", @paid_order.payment_processor.capitalize
      assert_select "td", @pending_order.payment_processor.capitalize
    end

    test "should filter orders by payment processor" do
      # Test Stripe filter
      get admin_payments_path, params: { payment_processor: "stripe" }
      assert_response :success
      assert_select "td", "Stripe"
      assert_select "td", { text: "Momo", count: 0 }

      # Test MoMo filter
      get admin_payments_path, params: { payment_processor: "momo" }
      assert_response :success
      assert_select "td", "Momo"
      assert_select "td", { text: "Stripe", count: 0 }
    end

    test "should filter orders by status" do
      # Test paid filter
      get admin_payments_path, params: { status: "paid" }
      assert_response :success
      assert_select "span.bg-green-100.text-green-800", "Paid"
      assert_select "span.bg-yellow-100.text-yellow-800", { count: 0 }

      # Test pending filter
      get admin_payments_path, params: { status: "pending" }
      assert_response :success
      assert_select "span.bg-yellow-100.text-yellow-800", "Pending"
      assert_select "span.bg-green-100.text-green-800", { count: 0 }
    end

    test "should search orders" do
      get admin_payments_path, params: { search: @user.email }
      assert_response :success
      assert_select "td", @paid_order.payment_processor.capitalize
    end

    test "should show order" do
      get admin_payment_path(@paid_order)
      assert_response :success

      # Verify that the show page displays the correct information
      assert_select "h1", "Order Details ##{@paid_order.id}"
      assert_select "dd", @paid_order.payment_processor.capitalize
      assert_select "dd", @user.email
    end

    test "should update order" do
      patch admin_payment_path(@pending_order), params: {
        order: {
          status: "paid",
          payment_status: "paid",
          notes: "Manually marked as paid"
        }
      }

      assert_redirected_to admin_payment_path(@pending_order)
      @pending_order.reload
      assert_equal "paid", @pending_order.status
      assert_equal "paid", @pending_order.payment_status
      assert_equal "Manually marked as paid", @pending_order.notes
    end

    test "should create download link when digital order is marked paid" do
      # Attach a mock digital file to the product
      @product.stub(:digital_file, OpenStruct.new(
        attached?: true,
        filename: OpenStruct.new(to_s: "test.pdf"),
        byte_size: 1024,
        content_type: "application/pdf"
      )) do
        # Update a pending order to paid
        assert_difference("DownloadLink.count") do
          patch admin_payment_path(@pending_order), params: {
            order: {
              status: "paid",
              payment_status: "paid"
            }
          }
        end

        # Verify a download link was created
        download_link = DownloadLink.last
        assert_equal @pending_order.id, download_link.order_id
        assert_equal @user.id, download_link.user_id
        assert_equal @product.id, download_link.product_id
      end
    end
  end
end
