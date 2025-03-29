# frozen_string_literal: true

require "application_system_test_case"

class SuperAdminLoginTest < ApplicationSystemTestCase
  setup do
    # Create a super admin user
    @super_admin = users(:one)
    @super_admin.update(super_admin: true, email: "super@example.com", password: "password123")

    # Create a regular admin user
    @admin = users(:two)
    @admin.update(admin: true)
  end

  test "visiting the super admin login page" do
    visit super_admin_login_form_path

    # Check page title and form
    assert_selector "h1", text: "Super Admin Login"
    assert_selector "form[action='#{super_admin_login_path}']"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
    assert_selector "input[type='submit']"
  end

  test "logging in as super admin" do
    visit super_admin_login_form_path

    # Fill in the form
    fill_in "Email Address", with: @super_admin.email
    fill_in "Password", with: "password123"
    click_on "Sign In"

    # Should be redirected to super admin dashboard
    assert_current_path super_admin_dashboard_path
    assert_selector "h1", text: "Super Admin Dashboard"
  end

  test "attempting to login with invalid credentials" do
    visit super_admin_login_form_path

    # Fill in the form with wrong password
    fill_in "Email Address", with: @super_admin.email
    fill_in "Password", with: "wrongpassword"
    click_on "Sign In"

    # Should stay on login page with error
    assert_current_path super_admin_login_path
    assert_selector ".login-alert", text: "Invalid email or password"
  end

  test "attempting to login as regular admin" do
    visit super_admin_login_form_path

    # Fill in the form with admin credentials
    fill_in "Email Address", with: @admin.email
    fill_in "Password", with: "password123"
    click_on "Sign In"

    # Should stay on login page with error
    assert_current_path super_admin_login_path
    assert_selector ".login-alert", text: "This account does not have super admin privileges"
  end

  test "accessing super admin login when already logged in" do
    # Sign in as super admin
    sign_in @super_admin

    # Visit login page
    visit super_admin_login_form_path

    # Should be redirected to dashboard
    assert_current_path super_admin_dashboard_path
    assert_selector ".login-notice", text: "You are already logged in as a super admin"
  end

  test "accessing super admin area directly" do
    # Try to visit super admin dashboard without logging in
    visit super_admin_dashboard_path

    # Should be redirected to login page
    assert_current_path super_admin_login_form_path
    assert_selector ".login-alert", text: "You must be a super administrator to access this area"
  end
end
