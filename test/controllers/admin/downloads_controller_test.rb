# frozen_string_literal: true

require "test_helper"

module Admin
  class DownloadsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = users(:one)
      @admin.update(admin: true)
      sign_in @admin

      @product = products(:digital)
      @user = users(:two)

      @download_link = DownloadLink.create!(
        user: @user,
        product: @product,
        expires_at: 7.days.from_now,
        download_limit: 5,
        download_count: 2,
        active: true,
        file_name: "test.pdf",
        file_size: 1024,
        content_type: "application/pdf"
      )

      # Create an expired download link
      @expired_link = DownloadLink.create!(
        user: @user,
        product: @product,
        expires_at: 2.days.ago,
        download_limit: 5,
        download_count: 0,
        active: true,
        file_name: "expired.pdf",
        file_size: 1024,
        content_type: "application/pdf"
      )
    end

    test "should redirect non-admin users" do
      regular_user = users(:two)
      sign_in regular_user

      get admin_downloads_path
      assert_redirected_to root_path
      assert_equal "You must be an administrator to access this area.", flash[:alert]
    end

    test "should get index" do
      get admin_downloads_path
      assert_response :success

      # Verify that the index shows the expected content
      assert_select "h1", "Download Links"

      # Check that our test download links are in the table
      assert_select "td", @download_link.product.name
      assert_select "td", @user.email
    end

    test "should filter download links" do
      # Test active filter
      get admin_downloads_path, params: { filter: "active" }
      assert_response :success
      assert_select "td", @download_link.product.name

      # Test expired filter
      get admin_downloads_path, params: { filter: "expired" }
      assert_response :success
      assert_select "td", @expired_link.product.name
    end

    test "should search download links" do
      get admin_downloads_path, params: { search: @user.email }
      assert_response :success
      assert_select "td", @download_link.product.name
    end

    test "should show download link" do
      get admin_download_path(@download_link)
      assert_response :success

      # Verify that the show page displays the correct information
      assert_select "h1", "Download Link Details"
      assert_select "dd", @download_link.product.name
      assert_select "dd", @user.email
    end

    test "should get edit" do
      get edit_admin_download_path(@download_link)
      assert_response :success

      # Verify that the edit page shows the form
      assert_select "h1", "Edit Download Link"
      assert_select "form[action=?]", admin_download_path(@download_link)
    end

    test "should update download link" do
      new_limit = 10

      patch admin_download_path(@download_link), params: {
        download_link: {
          download_limit: new_limit,
          expires_at: 14.days.from_now,
          active: true
        }
      }

      assert_redirected_to admin_download_path(@download_link)
      @download_link.reload
      assert_equal new_limit, @download_link.download_limit
    end

    test "should regenerate download link" do
      original_token = @expired_link.token
      original_expires_at = @expired_link.expires_at

      post regenerate_admin_download_path(@expired_link), params: {
        expires_at: 14.days.from_now.strftime("%Y-%m-%dT%H:%M")
      }

      assert_redirected_to admin_download_path(@expired_link)
      @expired_link.reload

      # Check that the token was changed
      assert_not_equal original_token, @expired_link.token

      # Check that the expiration date was updated
      assert @expired_link.expires_at > Time.current
      assert_not_equal original_expires_at, @expired_link.expires_at

      # Check that the download count was reset
      assert_equal 0, @expired_link.download_count

      # Check that the link is now active
      assert @expired_link.active?
    end

    test "should destroy download link" do
      assert_difference("DownloadLink.count", -1) do
        delete admin_download_path(@download_link)
      end

      assert_redirected_to admin_downloads_path
    end
  end
end
