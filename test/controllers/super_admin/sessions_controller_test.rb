# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      # Create a super admin user
      @super_admin = users(:one)
      @super_admin.update(super_admin: true, email: "super@example.com", password: "password123")

      # Create a regular admin user
      @admin = users(:two)
      @admin.update(admin: true)

      # Create a regular user
      @user = users(:three) || users.create!(
        email: "regularuser@example.com",
        password: "password123",
        first_name: "Regular",
        last_name: "User"
      )
    end

    test "should get login form" do
      get super_admin_login_form_path
      assert_response :success

      # Should show login page
      assert_select "h1", "Super Admin Login"
    end

    test "should redirect if already logged in as super admin" do
      sign_in @super_admin

      get super_admin_login_form_path
      assert_redirected_to super_admin_dashboard_path
      assert_equal "You are already logged in as a super admin.", flash[:notice]
    end

    test "should redirect with message if logged in as regular admin" do
      sign_in @admin

      get super_admin_login_form_path
      assert_redirected_to admin_dashboard_path
      assert_match /not a super admin/, flash[:notice]
    end

    test "should redirect with message if logged in as regular user" do
      sign_in @user

      get super_admin_login_form_path
      assert_redirected_to root_path
      assert_match /do not have super admin privileges/, flash[:notice]
    end

    test "should login super admin with valid credentials" do
      post super_admin_login_path, params: {
        email: @super_admin.email,
        password: "password123"
      }

      assert_redirected_to super_admin_dashboard_path
      assert_equal "Welcome to the super admin dashboard.", flash[:notice]
    end

    test "should not login with invalid credentials" do
      post super_admin_login_path, params: {
        email: @super_admin.email,
        password: "wrongpassword"
      }

      assert_response :success # Renders the login form again
      assert_select ".login-alert", "Invalid email or password."
    end

    test "should not login non-super-admin user" do
      post super_admin_login_path, params: {
        email: @admin.email,
        password: "password123"
      }

      assert_response :success # Renders the login form again
      assert_select ".login-alert", "This account does not have super admin privileges."
    end

    test "should handle non-existent email" do
      post super_admin_login_path, params: {
        email: "nonexistent@example.com",
        password: "password123"
      }

      assert_response :success # Renders the login form again
      assert_select ".login-alert", "Invalid email or password."
    end
  end
end
