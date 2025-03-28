# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @cart = current_user.ensure_cart
    payment_method = params[:payment_method]

    case payment_method
    when 'stripe'
      create_stripe_checkout
    when 'momo'
      # This will be implemented later
      redirect_to new_checkout_path, alert: 'Mobile Money payment is coming soon!'
    else
      redirect_to new_checkout_path, alert: 'Please select a valid payment method'
    end
  end

  def stripe_success
    session_id = params[:session_id]
    
    if session_id.present?
      # Process the successful payment
      stripe_service = StripeService.new(current_user)
      checkout_session = stripe_service.retrieve_checkout_session(session_id)
      
      if checkout_session.payment_status == 'paid'
        # Create order from session
        @order = create_order_from_session(checkout_session)
        redirect_to order_path(@order), notice: 'Payment successful! Your order has been placed.'
      else
        redirect_to cart_path, alert: 'Payment is still being processed. We will notify you when confirmed.'
      end
    else
      redirect_to cart_path, alert: 'Could not verify payment. Please contact support.'
    end
  end

  def stripe_cancel
    redirect_to cart_path, alert: 'Payment was cancelled. Your cart is still saved.'
  end

  private

  def create_stripe_checkout
    stripe_service = StripeService.new(current_user)
    session = stripe_service.create_checkout_session(@cart)
    
    # Store session ID to match with webhook 
    # This could be stored in the cart, user session, or a pending order
    session[:stripe_checkout_id] = session.id

    redirect_to session.url, allow_other_host: true
  end

  def create_order_from_session(checkout_session)
    # Create a new order from checkout information
    # In a real app, you might have created a pending order earlier and update it here
    @cart = current_user.ensure_cart
    
    order = Order.create!(
      user: current_user,
      total_amount: @cart.total,
      payment_processor: 'stripe',
      payment_id: checkout_session.id,
      status: 'paid'
    )

    # Clear the cart after successful order
    @cart.clear
    
    order
  end
end