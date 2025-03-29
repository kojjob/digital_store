# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  class UsersControllerTest < ActionDispatch::IntegrationTest
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
      @user = users(:three) || users.create!(
        email: "regularuser@example.com",
        password: "password123",
        first_name: "Regular",
        last_name: "User"
      )
    end

    test "should redirect non-super-admin users" do
      # Sign in as regular admin
      sign_in @admin

      get super_admin_users_path
      assert_redirected_to admin_dashboard_path

      # Sign in as regular user
      sign_in @user

      get super_admin_users_path
      assert_redirected_to root_path
    end

    test "should get index" do
      get super_admin_users_path
      assert_response :success

      # Check for user listing elements
      assert_select "h1", "User Management"
      assert_select "table", { count: 1 }
    end

    test "should filter users by role" do
      # Filter admins
      get super_admin_users_path, params: { role: "admin" }
      assert_response :success

      # Filter super_admins
      get super_admin_users_path, params: { role: "super_admin" }
      assert_response :success
    end

    test "should search users" do
      get super_admin_users_path, params: { search: @user.email }
      assert_response :success

      # Should show the searched user
      assert_select "td", @user.email
    end

    test "should show user" do
      get super_admin_user_path(@user)
      assert_response :success

      # Check for user details
      assert_select "h1", /User Details/
      assert_select "dd", @user.email
    end

    test "should get edit" do
      get edit_super_admin_user_path(@user)
      assert_response :success

      # Check for edit form
      assert_select "h1", /Edit User/
      assert_select "form[action=?]", super_admin_user_path(@user)
    end

    test "should update user" do
      patch super_admin_user_path(@user), params: {
        user: {
          first_name: "Updated",
          last_name: "Name",
          admin: true
        }
      }

      assert_redirected_to super_admin_user_path(@user)

      # Reload user and check for updates
      @user.reload
      assert_equal "Updated", @user.first_name
      assert_equal "Name", @user.last_name
      assert @user.admin?
    end

    test "cannot edit super admin user" do
      # Attempt to edit super admin as another super admin
      get edit_super_admin_user_path(@super_admin)

      # Should show but with limited options
      assert_response :success
      assert_select "input[name='user[admin]']", { count: 0 }
    end

    test "should toggle admin status" do
      assert_not @user.admin?

      # Make user an admin
      post toggle_admin_super_admin_user_path(@user)

      assert_redirected_to super_admin_user_path(@user)

      # Check user is now admin
      @user.reload
      assert @user.admin?

      # Toggle back to regular user
      post toggle_admin_super_admin_user_path(@user)

      # Check user is no longer admin
      @user.reload
      assert_not @user.admin?
    end

    test "cannot toggle super admin status" do
      # Attempt to toggle super admin
      post toggle_admin_super_admin_user_path(@super_admin)

      assert_redirected_to super_admin_users_path
    end

    test "should impersonate user" do
      # Initial user is super admin
      assert_equal @super_admin.id, session["warden.user.user.key"][0][0]

      # Impersonate regular user
      post impersonate_super_admin_user_path(@user)

      # Check redirected to root
      assert_redirected_to root_path

      # Check now logged in as different user
      assert_equal @user.id, session["warden.user.user.key"][0][0]

      # Check admin ID stored in session for returning
      assert_equal @super_admin.id, session[:admin_id]
    end

    test "should stop impersonation" do
      # Setup impersonation
      session[:admin_id] = @super_admin.id
      sign_in @user

      # Stop impersonation
      post stop_impersonation_super_admin_users_path

      # Check redirected to super admin users path
      assert_redirected_to super_admin_users_path

      # Check now logged in as super admin again
      assert_equal @super_admin.id, session["warden.user.user.key"][0][0]

      # Check admin ID removed from session
      assert_nil session[:admin_id]
    end
  end
end
