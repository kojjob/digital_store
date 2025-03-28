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
    # Process the checkout
    # This would typically include payment processing, order creation, etc.

    # For now, just create a simple order
    @cart = current_user.ensure_cart

    # Create order from cart
    # This is a placeholder - you would need to implement actual order creation logic
    order = Order.new(
      user: current_user,
      total_amount: @cart.total
    )

    if order.save
      # Clear the cart after successful order
      @cart.clear

      redirect_to order_path(order), notice: "Order placed successfully!"
    else
      redirect_to checkout_path, alert: "There was a problem processing your order."
    end
  end

  private

  def checkout_params
    params.require(:checkout).permit(:shipping_address, :payment_method)
  end
end
