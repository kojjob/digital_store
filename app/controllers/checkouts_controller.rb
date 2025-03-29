class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def new
    # Get the product_id from params if it exists (for direct checkout)
    @product_id = params[:product_id]

    if @product_id.present?
      # Direct checkout from product page
      @product = Product.find(@product_id)
      # Create a temporary cart item for this product
      @cart = current_user.ensure_cart
      @cart.add_product(@product_id, 1) unless @cart.has_product?(@product_id)
    else
      # Regular checkout from cart
      @cart = current_user.ensure_cart

      # Redirect to cart if it's empty
      if @cart.cart_items.empty?
        redirect_to cart_path, alert: "Your cart is empty. Please add items before checkout."
        nil
      end
    end

    # Setup checkout information
    # This would typically include shipping address, payment methods, etc.
  end

  def create
    @cart = current_user.ensure_cart

    # Validate the payment method selection
    payment_method = params[:payment_method]

    if payment_method.blank?
      redirect_to checkout_path, alert: "Please select a payment method"
      return
    end

    # Create a pending order
    begin
      # Get the product (assuming single product checkouts for now)
      product = @product || @cart.cart_items.first&.product

      if product.nil?
        redirect_to checkout_path, alert: "Your cart is empty"
        return
      end

      # Create order
      order = Order.create!(
        user: current_user,
        product: product,
        total_amount: @cart.total,
        status: "pending",
        payment_status: "pending"
      )

      # Send order confirmation email
      OrderMailer.order_confirmation(order).deliver_later

      # Redirect to the payments controller to handle payment
      redirect_to create_payment_path(payment_method: payment_method, order_id: order.id)
    rescue => e
      Rails.logger.error("Error creating order: #{e.message}")
      redirect_to checkout_path, alert: "There was a problem processing your order. Please try again."
    end
  end

  private

  def checkout_params
    params.require(:checkout).permit(:shipping_address, :payment_method)
  end
end
