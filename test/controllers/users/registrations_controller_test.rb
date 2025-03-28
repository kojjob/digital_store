require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get edit page" do
    sign_in users(:valid_user)
    get edit_user_registration_path
    assert_response :success
  end

  test "should update profile without password" do
    user = users(:valid_user)
    sign_in user

    patch user_registration_path, params: {
      user: {
        first_name: "Updated",
        last_name: "Name"
      },
      commit_section: "profile"
    }

    assert_redirected_to root_path
  end
end
