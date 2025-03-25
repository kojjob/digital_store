require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @user = users(:valid_user)
    # Create a test image file
    @test_image = fixture_file_upload("test_image.jpg", "image/jpeg")
  end

  test "has_profile_picture? returns false for new user" do
    assert_not @user.has_profile_picture?
  end

  test "full_name returns combined first and last name" do
    assert_equal "John Doe", @user.full_name
  end

  test "full_name handles missing parts" do
    @user.first_name = nil
    assert_equal "Doe", @user.full_name

    @user.first_name = "John"
    @user.last_name = nil
    assert_equal "John", @user.full_name

    @user.first_name = nil
    assert_equal "", @user.full_name
  end

  test "can attach profile picture" do
    @user.profile_picture.attach(@test_image)
    assert @user.profile_picture.attached?
    assert @user.has_profile_picture?
  end

  test "can remove profile picture" do
    # First attach a profile picture
    @user.profile_picture.attach(@test_image)
    assert @user.profile_picture.attached?

    # Then set remove_profile_picture to "1" and save
    @user.remove_profile_picture = "1"
    @user.save

    # Profile picture should be gone
    assert_not @user.profile_picture.attached?
    assert_not @user.has_profile_picture?
  end
end
