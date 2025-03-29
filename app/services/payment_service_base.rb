# frozen_string_literal: true

# Base class for payment services to standardize behavior
class PaymentServiceBase
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Process webhook data - to be implemented by subclasses
  def self.process_webhook(payload, signature, headers = {})
    raise NotImplementedError, "Subclasses must implement process_webhook"
  end
  
  # Create a payment audit log entry
  def self.create_payment_audit_log(order, event_type, provider, data = {})
    begin
      PaymentAuditLog.create!(
        order_id: order.id,
        user_id: order.user_id,
        event_type: event_type,
        payment_processor: provider,
        amount: order.total_amount,
        transaction_id: order.payment_id,
        metadata: {
          provider_data: data,
          timestamp: Time.current
        }.to_json
      )
    rescue => e
      # Log but don't fail the webhook processing if audit logging fails
      Rails.logger.error("Failed to create payment audit log: #{e.message}")
    end
  end

  protected
  
  # Create a pending order for a payment attempt
  def create_pending_order(amount, payment_processor, payment_id, additional_details = {})
    order = Order.create!(
      user: @user,
      total_amount: amount,
      payment_processor: payment_processor,
      payment_id: payment_id,
      payment_status: "pending",
      status: "pending"
    )
    
    # Add additional details if present
    if additional_details.present?
      order.update(payment_details: additional_details.to_json)
    end
    
    order
  end
  
  # Handle a successful payment
  def handle_payment_success(order)
    # Update order status
    order.update(status: "paid", payment_status: "paid")
    
    # Create download links if applicable
    create_download_links(order)
    
    # Send confirmation emails
    OrderMailer.payment_confirmation(order).deliver_later
    
    # Clear the user's cart
    @user.ensure_cart.clear
    
    # Log the success
    Rails.logger.info("Order ##{order.id} marked as paid")
    
    # Return success response
    {
      success: true,
      status: "paid",
      order_id: order.id,
      message: "Payment completed successfully"
    }
  end
  
  # Handle a failed payment
  def handle_payment_failure(order, reason = nil)
    # Update order status
    order.update(status: "failed", payment_status: "failed")
    
    # Log the failure
    Rails.logger.info("Order ##{order.id} payment failed: #{reason}")
    
    # Return failure response
    {
      success: false,
      status: "failed",
      order_id: order.id,
      message: "Payment failed#{reason ? ": #{reason}" : ""}"
    }
  end
  
  # Create download links for digital products
  def create_download_links(order)
    if order.product.digital_file.attached?
      download_link = DownloadLink.create!(
        user: order.user,
        product: order.product,
        order: order,
        expires_at: 30.days.from_now,
        download_limit: 5,
        file_name: order.product.digital_file.filename.to_s,
        file_size: order.product.digital_file.byte_size,
        content_type: order.product.digital_file.content_type
      )
      
      # Send the download ready email
      OrderMailer.download_ready(download_link).deliver_later
      
      return download_link
    end
    
    nil
  end
  
  # Get secret from Rails credentials or environment variables
  def self.get_secret(service, key, env_var = nil)
    # Try to get from credentials first (more secure)
    secret = Rails.application.credentials.dig(service.to_sym, key.to_sym)
    
    # Fall back to environment variable if not found in credentials
    secret || (env_var.present? ? ENV.fetch(env_var, nil) : nil)
  end
end
