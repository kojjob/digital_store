# frozen_string_literal: true

require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = users(:one)
      @admin.update(admin: true)
      sign_in @admin

      # Create some test data
      @product = products(:digital)

      # Create orders
      @paid_order = Order.create!(
        user: @admin,
        product: @product,
        total_amount: 19.99,
        status: "paid",
        payment_processor: "stripe",
        payment_id: "test_payment_123",
        payment_status: "paid"
      )

      @pending_order = Order.create!(
        user: @admin,
        product: @product,
        total_amount: 29.99,
        status: "pending",
        payment_processor: "momo",
        payment_id: "test_payment_456",
        payment_status: "pending"
      )

      # Create download links
      @download_link = DownloadLink.create!(
        user: @admin,
        product: @product,
        order: @paid_order,
        expires_at: 7.days.from_now,
        download_limit: 5,
        download_count: 2,
        active: true,
        file_name: "test.pdf",
        file_size: 1024,
        content_type: "application/pdf"
      )

      # Create download activity
      UserActivity.create!(
        user: @admin,
        activity_type: "download",
        title: "Downloaded #{@product.name}",
        description: "Downloaded #{@product.name}",
        reference_type: "Product",
        reference_id: @product.id
      )
    end

    test "should redirect non-admin users" do
      regular_user = users(:two)
      sign_in regular_user

      get admin_dashboard_path
      assert_redirected_to root_path
      assert_equal "You must be an administrator to access this area.", flash[:alert]
    end

    test "should get dashboard index" do
      get admin_dashboard_path
      assert_response :success

      # Verify that the dashboard shows the expected content
      assert_select "h1", "Admin Dashboard"

      # Check stats
      assert_select ".overflow-hidden.rounded-lg.bg-white.shadow", { minimum: 4 }

      # Check for recent orders section
      assert_select "h2", "Recent Orders"

      # Check for recent downloads section
      assert_select "h2", "Recent Downloads"
    end

    test "should get analytics" do
      get admin_analytics_path
      assert_response :success

      # Verify that the analytics page shows the expected content
      assert_select "h1", "Analytics Dashboard"

      # Check for date range filter
      assert_select "h3", "Filter by Date Range"

      # Check for charts
      assert_select "canvas#salesChart"
      assert_select "canvas#downloadsChart"
      assert_select "canvas#categorySalesChart"
      assert_select "canvas#paymentMethodChart"
    end

    test "analytics should accept date range params" do
      get admin_analytics_path, params: {
        start_date: 10.days.ago.strftime("%Y-%m-%d"),
        end_date: Date.today.strftime("%Y-%m-%d")
      }
      assert_response :success
    end
  end
end
