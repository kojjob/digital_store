# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart, only: [ :create, :momo_initiate ]
  before_action :validate_order, only: [ :create ]

  def create
    payment_method = params[:payment_method]

    case payment_method
    when "stripe"
      create_stripe_checkout
    when "momo"
      create_momo_payment
    else
      redirect_to new_checkout_path, alert: "Please select a valid payment method"
    end
  end

  def stripe_success
    begin
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

          if checkout_session.payment_status == "paid"
            # Update the existing pending order
            order.update(status: "paid", payment_status: "paid")

            # Create a download link if this is a digital product with a file
            if order.product.digital_file.attached?
              download_link = DownloadLink.create!(
                user: current_user,
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

            # Clear the cart after successful order
            @cart.clear

            redirect_to order_path(order), notice: "Payment successful! Your order has been placed."
          else
            redirect_to cart_path, alert: "Payment is still being processed. We will notify you when confirmed."
          end
        else
          # Order not found or validation failed - security issue
          Rails.logger.error("Security warning: Payment session validation failed for user #{current_user.id}")
          redirect_to cart_path, alert: "Payment verification failed. Please contact support."
        end
      else
        redirect_to cart_path, alert: "Could not verify payment. Please contact support."
      end
    ensure
      # Always clear session data for security
      session.delete(:checkout_session_id)
      session.delete(:pending_order_id)
    end
  end

  def stripe_cancel
    begin
      # Clean up session data
      checkout_session_id = session.delete(:checkout_session_id)
      pending_order_id = session.delete(:pending_order_id)

      # If we had a pending order, mark it as cancelled
      if pending_order_id.present?
        order = current_user.orders.find_by(id: pending_order_id)
        if order && order.status == "pending"
          order.update(status: "cancelled", payment_status: "cancelled")
          Rails.logger.info("Order ##{order.id} cancelled by user during checkout")
        end
      end

      redirect_to cart_path, alert: "Payment was cancelled. Your cart is still saved."
    ensure
      # Always clear session data for security
      session.delete(:checkout_session_id)
      session.delete(:pending_order_id)
    end
  end

  # Mobile Money payment flow
  def momo_initiate
    # Validate the provider and phone number
    provider = params[:provider]&.downcase
    phone_number = params[:phone_number]

    if provider.blank? || phone_number.blank?
      redirect_to checkout_path, alert: "Provider and phone number are required for mobile money payments."
      return
    end

    # Create the mobile money payment request
    momo_service = MomoService.new(current_user)
    result = momo_service.initiate_payment(@cart, phone_number, provider)

    if result[:success]
      # Store the transaction reference in the session
      session[:momo_transaction_ref] = result[:transaction_ref]
      session[:pending_order_id] = result[:order_id]

      # Redirect to the verification page
      redirect_to momo_verify_path(result[:transaction_ref]), notice: result[:message]
    else
      redirect_to checkout_path, alert: result[:error] || "Could not process mobile money payment. Please try again."
    end
  end

  def momo_verify
    transaction_ref = params[:transaction_ref]

    # Verify the transaction reference matches the one in the session
    if transaction_ref != session[:momo_transaction_ref]
      redirect_to cart_path, alert: "Invalid payment verification. Please try again."
      return
    end

    # Verify the payment status
    momo_service = MomoService.new(current_user)
    result = momo_service.verify_payment(transaction_ref)

    if result[:success]
      # Clear the session data
      session.delete(:momo_transaction_ref)
      session.delete(:pending_order_id)

      # Redirect to the order page
      redirect_to order_path(result[:order_id]), notice: "Payment successful! Your order has been placed."
    else
      # Keep the session data for retrying
      @transaction_ref = transaction_ref
      render :momo_verification
    end
  end

  private

  def ensure_cart
    @cart = current_user.ensure_cart
  end

  def validate_order
    order_id = params[:order_id]

    # Find the order if order_id is provided
    if order_id.present?
      @order = current_user.orders.find_by(id: order_id)
      if @order.nil?
        redirect_to new_checkout_path, alert: "Order not found"
        return false
      end
    end

    true
  end

  def create_momo_payment
    # Render the mobile money payment form
    render :momo_payment
  end

  def create_stripe_checkout
    stripe_service = StripeService.new(current_user)
    checkout_session = stripe_service.create_checkout_session(@cart)

    # Create a pending order to track this payment attempt
    order = Order.create!(
      user: current_user,
      total_amount: @cart.total,
      payment_processor: "stripe",
      payment_id: checkout_session.id,
      payment_status: "pending",
      status: "pending"
    )

    # Use Rails encrypted session to store sensitive data temporarily
    session[:checkout_session_id] = checkout_session.id
    session[:pending_order_id] = order.id

    redirect_to checkout_session.url, allow_other_host: true
  end
end
