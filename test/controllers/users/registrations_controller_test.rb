require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    @user = users(:valid_user)
    sign_in @user
    @test_image = fixture_file_upload("test_image.jpg", "image/jpeg")
  end

  test "should update profile without requiring current password" do
    patch user_registration_path, params: {
      user: {
        first_name: "Updated",
        last_name: "Name"
      },
      commit_section: "profile"
    }

    assert_redirected_to root_path
    @user.reload
    assert_equal "Updated", @user.first_name
    assert_equal "Name", @user.last_name
  end

  test "should update profile with profile picture" do
    patch user_registration_path, params: {
      user: {
        first_name: "Updated",
        last_name: "Name",
        profile_picture: @test_image
      },
      commit_section: "profile"
    }

    assert_redirected_to root_path
    @user.reload
    assert @user.profile_picture.attached?
  end

  test "should require current password for security section" do
    patch user_registration_path, params: {
      user: {
        password: "newpassword",
        password_confirmation: "newpassword"
      },
      commit_section: "security"
    }

    assert_response :unprocessable_entity
  end

  test "should require current password for email change" do
    patch user_registration_path, params: {
      user: {
        email: "newemail@example.com"
      }
    }

    assert_response :unprocessable_entity
  end

  test "should update password with current password" do
    patch user_registration_path, params: {
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123",
        current_password: "password123"
      },
      commit_section: "security"
    }

    assert_redirected_to root_path
  end

  test "should remove profile picture when remove flag is set" do
    # First attach a profile picture
    @user.profile_picture.attach(@test_image)
    @user.save
    assert @user.profile_picture.attached?

    # Submit update with remove_profile_picture set to "1"
    patch user_registration_path, params: {
      user: {
        remove_profile_picture: "1"
      },
      commit_section: "profile"
    }

    assert_redirected_to root_path
    @user.reload
    assert_not @user.profile_picture.attached?
  end
end
