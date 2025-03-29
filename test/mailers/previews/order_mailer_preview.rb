# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def order_confirmation
    order = Order.first || create_sample_order
    OrderMailer.order_confirmation(order)
  end

  def payment_confirmation
    order = Order.first || create_sample_order
    OrderMailer.payment_confirmation(order)
  end

  def download_ready
    download_link = DownloadLink.first || create_sample_download_link
    OrderMailer.download_ready(download_link)
  end

  def download_expiring
    download_link = DownloadLink.first || create_sample_download_link
    OrderMailer.download_expiring(download_link)
  end

  private

  def create_sample_order
    user = User.first || User.create!(
      email: "example@example.com",
      password: "password",
      name: "Example User"
    )

    product = Product.first || Product.create!(
      name: "Sample Digital Product",
      description: "This is a sample digital product for testing.",
      price: 29.99,
      category: Category.first || Category.create!(name: "Test Category"),
      seller: Seller.first || user.create_seller(name: "Test Seller")
    )

    Order.create!(
      user: user,
      total_amount: product.price,
      status: "pending",
      payment_processor: "stripe",
      payment_id: "preview_test_id"
    )
  end

  def create_sample_download_link
    order = Order.first || create_sample_order
    product = order.product || Product.first
    user = order.user || User.first

    DownloadLink.create!(
      user: user,
      product: product,
      order: order,
      expires_at: 3.days.from_now,
      download_limit: 5,
      download_count: 2,
      active: true,
      file_name: "sample_file.pdf",
      file_size: 1024,
      content_type: "application/pdf"
    )
  end
end
