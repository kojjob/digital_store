# frozen_string_literal: true

require "test_helper"

class DownloadLinkTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:digital)
    @order = orders(:one)
  end

  test "should create a valid download link" do
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5
    )

    assert download_link.valid?
    assert download_link.save

    # Check default values
    assert_equal 0, download_link.download_count
    assert download_link.active?
    assert download_link.token.present?
  end

  test "should not create download link without required fields" do
    # Test missing user
    download_link = DownloadLink.new(
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5
    )
    assert_not download_link.valid?

    # Test missing product
    download_link = DownloadLink.new(
      user: @user,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5
    )
    assert_not download_link.valid?

    # Test missing expires_at
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      download_limit: 5
    )
    assert_not download_link.valid?
  end

  test "order should be optional" do
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      expires_at: 7.days.from_now,
      download_limit: 5
    )

    assert download_link.valid?
  end

  test "should validate download limit is non-negative" do
    # Test negative download limit
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: -1
    )
    assert_not download_link.valid?

    # Test zero download limit (unlimited downloads)
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 0
    )
    assert download_link.valid?
  end

  test "should generate unique token" do
    download_link1 = DownloadLink.create!(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5
    )

    download_link2 = DownloadLink.create!(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5
    )

    assert download_link1.token.present?
    assert download_link2.token.present?
    assert_not_equal download_link1.token, download_link2.token
  end

  test "should check if link is valid for download" do
    # Valid link
    valid_link = download_links(:valid)
    assert valid_link.valid_for_download?

    # Expired link
    expired_link = download_links(:expired)
    assert_not expired_link.valid_for_download?

    # Link that reached download limit
    limit_reached_link = download_links(:limit_reached)
    assert_not limit_reached_link.valid_for_download?

    # Inactive link
    inactive_link = download_links(:inactive)
    assert_not inactive_link.valid_for_download?
  end

  test "should correctly identify expired links" do
    # Not expired
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 1.day.from_now,
      download_limit: 5
    )
    assert_not download_link.expired?

    # Expired
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 1.day.ago,
      download_limit: 5
    )
    assert download_link.expired?
  end

  test "should correctly identify links that reached download limit" do
    # Within limit
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 4
    )
    assert_not download_link.download_limit_reached?

    # At limit
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 5
    )
    assert download_link.download_limit_reached?

    # Unlimited downloads (limit = 0)
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 7.days.from_now,
      download_limit: 0,
      download_count: 100
    )
    assert_not download_link.download_limit_reached?
  end

  test "should increment download count" do
    download_link = download_links(:valid)
    original_count = download_link.download_count

    download_link.increment_download_count!
    assert_equal original_count + 1, download_link.download_count
  end

  test "should deactivate download link" do
    download_link = download_links(:valid)
    assert download_link.active?

    download_link.deactivate!
    assert_not download_link.active?
  end

  test "should regenerate download link" do
    download_link = download_links(:expired)
    original_token = download_link.token
    original_expires_at = download_link.expires_at

    download_link.regenerate!

    assert_not_equal original_token, download_link.token
    assert download_link.expires_at > Time.current
    assert_not_equal original_expires_at, download_link.expires_at
    assert_equal 0, download_link.download_count
    assert download_link.active?
  end

  test "should format expiration in words" do
    # Future date (days)
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 5.days.from_now,
      download_limit: 5
    )
    assert_match /Expires in \d+ days/, download_link.expiration_in_words

    # Future date (hours)
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 5.hours.from_now,
      download_limit: 5
    )
    assert_match /Expires in \d+ hours/, download_link.expiration_in_words

    # Expired
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      expires_at: 5.days.ago,
      download_limit: 5
    )
    assert_equal "Expired", download_link.expiration_in_words

    # No expiration
    download_link = DownloadLink.new(
      user: @user,
      product: @product,
      order: @order,
      download_limit: 5
    )
    assert_equal "No expiration", download_link.expiration_in_words
  end
end
