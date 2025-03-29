# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  # Set default from address
  default from: "notifications@digitalstore.com"

  # Send order confirmation email
  def order_confirmation(order)
    @order = order
    @user = order.user
    @product = order.product

    mail(
      to: @user.email,
      subject: "Your order ##{@order.id} confirmation"
    )
  end

  # Send payment confirmation email
  def payment_confirmation(order, recipient = nil, additional_message = nil)
    @order = order
    @user = order.user
    @product = order.product
    @additional_message = additional_message

    # Check for download link (will be nil if not a digital product)
    @download_link = DownloadLink.find_by(order: @order, user: @user)

    mail(
      to: recipient || @user.email,
      subject: "Payment received for order ##{@order.id}"
    )
  end

  # Send download link email
  def download_ready(download_link)
    @download_link = download_link
    @user = download_link.user
    @product = download_link.product
    @order = download_link.order

    # Generate the download URL with the full host
    @download_url = download_url(@download_link.token, host: "digitalstore.com")

    mail(
      to: @user.email,
      subject: "Your download for #{@product.name} is ready!"
    )
  end

  # Send email when download is about to expire
  def download_expiring(download_link)
    @download_link = download_link
    @user = download_link.user
    @product = download_link.product
    @order = download_link.order

    # Calculate days left
    @days_left = ((@download_link.expires_at - Time.current) / 1.day).round

    # Generate the download URL with the full host
    @download_url = download_url(@download_link.token, host: "digitalstore.com")

    mail(
      to: @user.email,
      subject: "Your download for #{@product.name} is expiring soon!"
    )
  end
end
