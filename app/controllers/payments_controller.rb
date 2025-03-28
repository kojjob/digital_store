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
    # Get the session ID from the Rails session, not from params
    checkout_session_id = session.delete(:checkout_session_id)
    pending_order_id = session.delete(:pending_order_id)
    
    # Verify we have the expected session data
    if checkout_session_id.present? && pending_order_id.present?
      # Get the order and validate it belongs to the current user (prevents session fixation)
      order = current_user.orders.find_by(id: pending_order_id)
      
      if order && order.payment_id == checkout_session_id
        # Process the successful payment
        stripe_service = StripeService.new(current_user)
        checkout_session = stripe_service.retrieve_checkout_session(checkout_session_id)
        
        if checkout_session.payment_status == 'paid'
          # Update the existing pending order
          order.update(status: 'paid', payment_status: 'paid')
          
          # Clear the cart after successful order
          @cart.clear
          
          redirect_to order_path(order), notice: 'Payment successful! Your order has been placed.'
        else
          redirect_to cart_path, alert: 'Payment is still being processed. We will notify you when confirmed.'
        end
      else
        # Order not found or validation failed - security issue
        Rails.logger.error("Security warning: Payment session validation failed for user #{current_user.id}")
        redirect_to cart_path, alert: 'Payment verification failed. Please contact support.'
      end
    else
      redirect_to cart_path, alert: 'Could not verify payment. Please contact support.'
    end
  end

  def stripe_cancel
    # Clean up session data
    checkout_session_id = session.delete(:checkout_session_id)
    pending_order_id = session.delete(:pending_order_id)
    
    # If we had a pending order, mark it as cancelled
    if pending_order_id.present?
      order = current_user.orders.find_by(id: pending_order_id)
      if order && order.status == 'pending'
        order.update(status: 'cancelled', payment_status: 'cancelled')
        Rails.logger.info("Order ##{order.id} cancelled by user during checkout")
      end
    end
    
    redirect_to cart_path, alert: 'Payment was cancelled. Your cart is still saved.'
  end

  private

  def create_stripe_checkout
    stripe_service = StripeService.new(current_user)
    checkout_session = stripe_service.create_checkout_session(@cart)
    
    # Create a pending order to track this payment attempt
    order = Order.create!(
      user: current_user,
      total_amount: @cart.total,
      payment_processor: 'stripe',
      payment_id: checkout_session.id,
      payment_status: 'pending',
      status: 'pending'
    )
    
    # Use Rails encrypted session to store sensitive data temporarily
    session[:checkout_session_id] = checkout_session.id
    session[:pending_order_id] = order.id

    redirect_to checkout_session.url, allow_other_host: true
  end

  # This method is no longer used - we now create a pending order first and update it
  # Keeping this as a reference for now
  def legacy_create_order_from_session(checkout_session)
    # This is only kept for reference and should not be used
    Rails.logger.warn("SECURITY WARNING: legacy_create_order_from_session should not be called")
    nil
  end
end