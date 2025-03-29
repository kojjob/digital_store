# frozen_string_literal: true

require "application_system_test_case"

class AdminDashboardTest < ApplicationSystemTestCase
  setup do
    # Create an admin user
    @admin = users(:one)
    @admin.update(admin: true)

    # Create a regular user
    @user = users(:two)

    # Create test data
    @product = products(:digital)

    # Create an order
    @order = Order.create!(
      user: @user,
      product: @product,
      total_amount: 29.99,
      status: "paid",
      payment_processor: "stripe",
      payment_id: "test_payment_id",
      payment_status: "paid"
    )

    # Create a download link
    @download_link = DownloadLink.create!(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 2,
      active: true,
      file_name: "test.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )
  end

  test "visiting the admin dashboard as an admin" do
    # Sign in as admin
    sign_in @admin

    # Visit the admin dashboard
    visit admin_dashboard_path

    # Check page title
    assert_selector "h1", text: "Admin Dashboard"

    # Check navigation links
    assert_selector "a", text: "Analytics"
    assert_selector "a", text: "Downloads"
    assert_selector "a", text: "Payments"

    # Check stats are displayed
    assert_selector "dt", text: "Total Revenue"

    # Check recent orders section
    assert_selector "h2", text: "Recent Orders"

    # Check recent downloads section
    assert_selector "h2", text: "Recent Downloads"
  end

  test "admin can navigate to different sections" do
    sign_in @admin

    # Start at the dashboard
    visit admin_dashboard_path

    # Go to Analytics
    click_on "Analytics"
    assert_selector "h1", text: "Analytics Dashboard"

    # Go to Downloads
    click_on "Downloads"
    assert_selector "h1", text: "Download Links"

    # View a specific download
    first("a", text: "View").click
    assert_selector "h1", text: "Download Link Details"

    # Go back to Downloads
    click_on "Back to Downloads"

    # Go to Payments
    click_on "Payments"
    assert_selector "h1", text: "Payment Management"

    # View a specific payment
    first("a", text: "View").click
    assert_selector "h1", text: /Order Details #\d+/
  end

  test "regular users cannot access the admin dashboard" do
    sign_in @user

    # Try to visit admin dashboard
    visit admin_dashboard_path

    # Should be redirected to homepage with error
    assert_selector ".alert", text: "You must be an administrator to access this area."
    assert_current_path root_path
  end

  test "admin can filter and search downloads" do
    sign_in @admin

    # Go to Downloads
    visit admin_downloads_path

    # Filter by active status
    select "Active", from: "filter"
    click_on "Apply"

    # Should show active downloads
    assert_selector "span", text: "Active"

    # Search by user email
    fill_in "search", with: @user.email
    click_on "Apply"

    # Should show results for that user
    assert_text @user.email
  end

  test "admin can filter and search payments" do
    sign_in @admin

    # Go to Payments
    visit admin_payments_path

    # Filter by payment method
    select "Stripe", from: "payment_processor"
    click_on "Apply"

    # Should show Stripe payments
    assert_selector "td", text: "Stripe"

    # Filter by status
    select "Paid", from: "status"
    click_on "Apply"

    # Should show paid orders
    assert_selector "span", text: "Paid"

    # Search by user email
    fill_in "search", with: @user.email
    click_on "Apply"

    # Should show results for that user
    assert_text @user.email
  end
end
