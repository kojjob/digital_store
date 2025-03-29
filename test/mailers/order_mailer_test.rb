# frozen_string_literal: true

require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @product = products(:digital)
    @order = orders(:one)

    # Create a download link for testing
    @download_link = DownloadLink.create!(
      user: @user,
      product: @product,
      order: @order,
      token: "test_token_12345",
      expires_at: 7.days.from_now,
      download_limit: 5,
      download_count: 0,
      active: true,
      file_name: "test_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )
  end

  test "order_confirmation" do
    email = OrderMailer.order_confirmation(@order)

    # Check basic email attributes
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [ "notifications@digitalstore.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_equal "Your order ##{@order.id} confirmation", email.subject

    # Check content
    assert_match @order.id.to_s, email.body.to_s
    assert_match @product.name, email.body.to_s
  end

  test "payment_confirmation" do
    email = OrderMailer.payment_confirmation(@order)

    # Check basic email attributes
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [ "notifications@digitalstore.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_equal "Payment received for order ##{@order.id}", email.subject

    # Check content
    assert_match @order.id.to_s, email.body.to_s
    assert_match @product.name, email.body.to_s
    assert_match "payment has been received", email.body.to_s.downcase
  end

  test "download_ready" do
    email = OrderMailer.download_ready(@download_link)

    # Check basic email attributes
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [ "notifications@digitalstore.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_equal "Your download for #{@product.name} is ready!", email.subject

    # Check content
    assert_match @product.name, email.body.to_s
    assert_match "download", email.body.to_s.downcase
    assert_match @download_link.token, email.body.to_s
  end

  test "download_expiring" do
    email = OrderMailer.download_expiring(@download_link)

    # Check basic email attributes
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [ "notifications@digitalstore.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_equal "Your download for #{@product.name} is expiring soon!", email.subject

    # Check content
    assert_match @product.name, email.body.to_s
    assert_match "expiring", email.body.to_s.downcase
    assert_match @download_link.token, email.body.to_s

    # Check days left is included
    days_left = ((@download_link.expires_at - Time.current) / 1.day).round
    assert_match days_left.to_s, email.body.to_s
  end
end
