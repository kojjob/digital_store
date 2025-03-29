# frozen_string_literal: true

require "application_system_test_case"

class SuperAdminTest < ApplicationSystemTestCase
  setup do
    # Create a super admin user
    @super_admin = users(:one)
    @super_admin.update(super_admin: true)

    # Create a regular admin user
    @admin = users(:two)
    @admin.update(admin: true)

    # Create a regular user
    @user = users(:three) || User.create!(
      email: "regularuser@example.com",
      password: "password123",
      first_name: "Regular",
      last_name: "User"
    )
  end

  test "visiting the super admin dashboard" do
    # Sign in as super admin
    sign_in @super_admin

    # Visit the super admin dashboard
    visit super_admin_dashboard_path

    # Check page title
    assert_selector "h1", text: "Super Admin Dashboard"

    # Check navigation links
    assert_selector "a", text: "Users"
    assert_selector "a", text: "System"

    # Check stats are displayed
    assert_selector "dt", text: "Total Users"

    # Check recent users section
    assert_selector "h2", text: "Recent Users"

    # Check recent orders section
    assert_selector "h2", text: "Recent Orders"
  end

  test "super admin can navigate to different sections" do
    sign_in @super_admin

    # Start at the dashboard
    visit super_admin_dashboard_path

    # Go to Users
    click_on "Users"
    assert_selector "h1", text: "User Management"

    # Go to System
    click_on "System"
    assert_selector "h1", text: "System Monitoring"

    # Go to Logs
    click_on "View Logs"
    assert_selector "h1", text: "Application Logs"
  end

  test "super admin can manage users" do
    sign_in @super_admin

    # Go to Users
    visit super_admin_users_path

    # View a user
    find("a[href='#{super_admin_user_path(@user)}']").click
    assert_selector "h1", text: "User Details"

    # Edit the user
    click_on "Edit User"
    assert_selector "h1", text: "Edit User"

    # Update the user
    fill_in "First name", with: "Updated"
    check "Admin" if has_field?("Admin") # Only if the field exists
    click_on "Update User"

    # Check the user was updated
    assert_selector "h1", text: "User Details"
    assert_text "User was successfully updated"
    assert_text "Updated"
  end

  test "super admin can impersonate users" do
    sign_in @super_admin

    # Go to a user's detail page
    visit super_admin_user_path(@user)

    # Click impersonate button
    click_on "Impersonate #{@user.email}"

    # Should show impersonation banner
    assert_selector "div", text: "You are currently impersonating #{@user.email}"

    # Should be on the home page
    assert_current_path root_path

    # Stop impersonation
    click_on "Stop Impersonation"

    # Should be back in super admin
    assert_selector "h1", text: "User Management"
  end

  test "regular admin cannot access super admin" do
    sign_in @admin

    # Try to visit super admin dashboard
    visit super_admin_dashboard_path

    # Should be redirected to admin dashboard with error
    assert_selector ".alert", text: "You must be a super administrator to access this area."
    assert_current_path admin_dashboard_path
  end

  test "super admin can view system information" do
    sign_in @super_admin

    # Go to System page
    visit super_admin_system_path

    # Check system information is displayed
    assert_selector "h3", text: "System Information"
    assert_selector "dt", text: "Rails Version"
    assert_selector "dt", text: "Ruby Version"
    assert_selector "dt", text: "Database"

    # Check database information is displayed
    assert_selector "h3", text: "Database Information"

    # Check storage information is displayed
    assert_selector "h3", text: "Storage Information"
  end
end
