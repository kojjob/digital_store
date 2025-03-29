# frozen_string_literal: true

require "test_helper"

class DownloadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:digital)
    sign_in @user

    # Create a download link for testing
    @download_link = DownloadLink.create!(
      user: @user,
      product: @product,
      token: "valid_token_123456",
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 0,
      active: true,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )

    # Create an expired download link
    @expired_link = DownloadLink.create!(
      user: @user,
      product: @product,
      token: "expired_token_123456",
      expires_at: 2.days.ago,
      download_limit: 5,
      download_count: 0,
      active: true,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )

    # Create a download link that reached its limit
    @limit_reached_link = DownloadLink.create!(
      user: @user,
      product: @product,
      token: "limit_reached_token_123456",
      expires_at: 7.days.from_now,
      download_limit: 3,
      download_count: 3,
      active: true,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )

    # Create an inactive download link
    @inactive_link = DownloadLink.create!(
      user: @user,
      product: @product,
      token: "inactive_token_123456",
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 0,
      active: false,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )
  end

  test "should redirect to login if not authenticated" do
    sign_out @user
    get downloads_path
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    get downloads_path
    assert_response :success
    assert_not_nil assigns(:download_links)
  end

  test "should increment download count when accessing valid download" do
    # Mock the attachment and redirect
    @product.stub(:digital_file, OpenStruct.new(attached?: true)) do
      get download_path(@download_link.token)

      # Reload download link and check count was incremented
      @download_link.reload
      assert_equal 1, @download_link.download_count
    end
  end

  test "should handle expired download links" do
    get download_path(@expired_link.token)

    assert_redirected_to downloads_path
    assert_equal "This download link has expired.", flash[:alert]
  end

  test "should handle links that reached download limit" do
    get download_path(@limit_reached_link.token)

    assert_redirected_to downloads_path
    assert_equal "You have reached the download limit for this file.", flash[:alert]
  end

  test "should handle inactive download links" do
    get download_path(@inactive_link.token)

    assert_redirected_to downloads_path
    assert_equal "This download link is no longer valid.", flash[:alert]
  end

  test "should handle non-existent download links" do
    get download_path("non_existent_token")

    assert_redirected_to downloads_path
    assert_equal "Invalid download link.", flash[:alert]
  end

  test "should handle products without attached files" do
    # Mock product so digital_file.attached? returns false
    @product.stub(:digital_file, OpenStruct.new(attached?: false)) do
      get download_path(@download_link.token)

      assert_redirected_to downloads_path
      assert_equal "This product does not have a digital file attached.", flash[:alert]
    end
  end

  test "should record user activity on download" do
    # Mock the attachment and redirect
    @product.stub(:digital_file, OpenStruct.new(attached?: true)) do
      # Count user activities before and after
      activity_count_before = UserActivity.where(user: @user, activity_type: "download").count

      get download_path(@download_link.token)

      activity_count_after = UserActivity.where(user: @user, activity_type: "download").count
      assert_equal activity_count_before + 1, activity_count_after
    end
  end
end
