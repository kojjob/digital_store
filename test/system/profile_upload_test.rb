require "application_system_test_case"

class ProfileUploadTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:valid_user)
    sign_in @user
    @test_image_path = Rails.root.join("test/fixtures/files/test_image.jpg")
  end

  test "user can navigate to profile settings" do
    visit edit_user_registration_path

    assert_selector "h2", text: "Profile Information"
    assert_selector "button", text: "Save profile"
  end

  test "user can update profile information" do
    visit edit_user_registration_path

    fill_in "First name", with: "Updated"
    fill_in "Last name", with: "Name"

    click_button "Save profile"

    assert_text "Your account has been updated successfully"
    @user.reload
    assert_equal "Updated", @user.first_name
    assert_equal "Name", @user.last_name
  end

  test "user can upload profile picture" do
    visit edit_user_registration_path

    # Attach the file to the hidden file field
    attach_file("user_profile_picture", @test_image_path, make_visible: true)

    # The Stimulus controller should update the file name display
    assert_text "Selected: test_image.jpg", wait: 5

    click_button "Save profile"

    assert_text "Your account has been updated successfully"
    @user.reload
    assert @user.profile_picture.attached?
  end

  test "user can remove profile picture" do
    # First attach a profile picture
    @user.profile_picture.attach(io: File.open(@test_image_path), filename: "test_image.jpg")
    @user.save

    visit edit_user_registration_path

    # The "Remove" button should be visible
    assert_text "Current: test_image.jpg"

    # Click the remove button
    click_button "Remove"

    # The file name should be updated
    assert_text "No image selected", wait: 5

    click_button "Save profile"

    assert_text "Your account has been updated successfully"
    @user.reload
    assert_not @user.profile_picture.attached?
  end
end
