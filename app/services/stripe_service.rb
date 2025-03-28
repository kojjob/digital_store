# frozen_string_literal: true

# Stripe service for handling payment operations
class StripeService
  def initialize(user)
    @user = user
  end

  def create_checkout_session(cart)
    line_items = prepare_line_items(cart)
    
    Stripe::Checkout::Session.create({
      customer_email: @user.email,
      payment_method_types: ['card'],
      line_items: line_items,
      mode: 'payment',
      success_url: "#{Rails.application.routes.url_helpers.orders_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: Rails.application.routes.url_helpers.cart_url
    })
  end

  def retrieve_checkout_session(session_id)
    Stripe::Checkout::Session.retrieve(session_id)
  end

  private

  def prepare_line_items(cart)
    cart.cart_items.map do |cart_item|
      {
        price_data: {
          currency: 'usd',
          product_data: {
            name: cart_item.product.name,
            description: cart_item.product.description&.truncate(100),
            images: [cart_item.product.primary_image_url].compact
          },
          unit_amount: (cart_item.product.price * 100).to_i # Stripe uses cents
        },
        quantity: cart_item.quantity
      }
    end
  end

  # Webhook handling
  def self.handle_webhook(payload, signature)
    event = nil
    
    begin
      # Verify webhook signature first
      webhook_secret = Rails.configuration.stripe[:webhook_secret]
      if webhook_secret.nil? || webhook_secret.empty?
        Rails.logger.error("SECURITY ERROR: Missing Stripe webhook secret")
        return { status: 500, error: "Configuration error" }
      end
      
      event = Stripe::Webhook.construct_event(
        payload, signature, webhook_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      Rails.logger.error("Webhook error - Invalid payload: #{e.message}")
      return { status: 400, error: "Invalid payload" }
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature - possible attack
      Rails.logger.error("SECURITY WARNING - Invalid Stripe signature: #{e.message}")
      return { status: 403, error: "Invalid signature" }
    rescue => e
      # General error
      Rails.logger.error("Webhook error - General exception: #{e.class.name} - #{e.message}")
      return { status: 500, error: "Internal error" }
    end

    # Process the verified event
    begin
      case event.type
      when 'checkout.session.completed'
        handle_checkout_completed(event)
      when 'payment_intent.succeeded'
        handle_payment_succeeded(event)
      when 'payment_intent.payment_failed'
        handle_payment_failed(event)
      else
        # Log but accept unknown event types
        Rails.logger.info("Received unhandled Stripe event type: #{event.type}")
      end
      
      { status: 200 }
    rescue => e
      Rails.logger.error("Error processing Stripe webhook: #{e.class.name} - #{e.message}")
      { status: 500, error: "Error processing webhook" }
    end
  end

  def self.handle_checkout_completed(event)
    session = event.data.object
    session_id = session.id
    
    # Find the pending order by its payment_id (the session ID)
    order = Order.find_by(payment_id: session_id, payment_processor: 'stripe')
    
    if order.nil?
      Rails.logger.error("Security warning: No order found for completed Stripe session: #{session_id}")
      return
    end
    
    # Double-check the payment status from Stripe's webhook 
    if session.payment_status == 'paid'
      # Update the order status
      order.update(
        status: 'paid',
        payment_status: 'paid'
      )
      
      # Create a download link if this is a digital product with a file
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
        
        # Send the payment confirmation and download ready emails
        OrderMailer.payment_confirmation(order).deliver_later
        OrderMailer.download_ready(download_link).deliver_later
      else
        # Send only the payment confirmation email
        OrderMailer.payment_confirmation(order).deliver_later
      end
      Rails.logger.info("Order ##{order.id} marked as paid via webhook")
      
      # Here you would trigger any post-payment processes
      # e.g., sending confirmation emails, generating download links, etc.
    else
      Rails.logger.warn("Stripe session #{session_id} marked as completed but not paid")
    end
  end

  def self.handle_payment_succeeded(event)
    payment_intent = event.data.object
    payment_intent_id = payment_intent.id
    
    # Log the success but don't include full payment details
    Rails.logger.info("Payment succeeded for intent: #{payment_intent_id}")
    
    # If you stored the payment_intent_id with the order, you could update it here
    # But typically this is handled by the checkout.session.completed event
  end

  def self.handle_payment_failed(event)
    payment_intent = event.data.object
    payment_intent_id = payment_intent.id
    
    # Log the failure but don't include full payment details
    Rails.logger.error("Payment failed for intent: #{payment_intent_id}")
    
    # If you stored the payment_intent_id with the order, you could update its status
    # Order.where(payment_intent_id: payment_intent_id).update_all(payment_status: 'failed')
  end
end