# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      # Create a super admin user
      @super_admin = users(:one)
      @super_admin.update(super_admin: true)
      sign_in @super_admin

      # Create a regular admin user
      @admin = users(:two)
      @admin.update(admin: true)

      # Create a regular user
      @user = users(:two)
    end

    test "should redirect non-super-admin users" do
      # Sign in as regular admin
      sign_in @admin

      get super_admin_dashboard_path
      assert_redirected_to admin_dashboard_path
      assert_equal "You must be a super administrator to access this area.", flash[:alert]

      # Sign in as regular user
      sign_in @user

      get super_admin_dashboard_path
      assert_redirected_to root_path
      assert_equal "You must be a super administrator to access this area.", flash[:alert]
    end

    test "should get dashboard" do
      get super_admin_dashboard_path
      assert_response :success

      # Check for dashboard elements
      assert_select "h1", "Super Admin Dashboard"

      # Stats should be present
      assert_select ".overflow-hidden.rounded-lg.bg-white.shadow", { minimum: 4 }
    end

    test "should get system page" do
      get super_admin_system_path
      assert_response :success

      # Check for system page elements
      assert_select "h1", "System Monitoring"

      # Should show Rails version
      assert_select "dt", "Rails Version"
    end

    test "should get logs" do
      get super_admin_logs_path
      assert_response :success

      # Check for logs page elements
      assert_select "h1", "Application Logs"
      assert_select "pre#log-content", { count: 1 }
    end

    test "should clear cache" do
      post super_admin_clear_cache_path

      assert_redirected_to super_admin_system_path
      assert_equal "Application cache has been cleared.", flash[:notice]
    end
  end
end
