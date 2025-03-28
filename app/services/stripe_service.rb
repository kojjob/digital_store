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
      event = Stripe::Webhook.construct_event(
        payload, signature, Rails.configuration.stripe[:webhook_secret]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("Webhook error: #{e.message}")
      return { status: 400, error: e.message }
    end

    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event)
    when 'payment_intent.succeeded'
      handle_payment_succeeded(event)
    when 'payment_intent.payment_failed'
      handle_payment_failed(event)
    end

    { status: 200 }
  end

  def self.handle_checkout_completed(event)
    session = event.data.object
    Rails.logger.info("Checkout completed for session: #{session.id}")
    # Process order fulfillment
    # Find order by session ID and mark as paid
  end

  def self.handle_payment_succeeded(event)
    payment_intent = event.data.object
    Rails.logger.info("Payment succeeded for intent: #{payment_intent.id}")
  end

  def self.handle_payment_failed(event)
    payment_intent = event.data.object
    Rails.logger.error("Payment failed for intent: #{payment_intent.id}")
  end
end