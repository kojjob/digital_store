class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    # Show the current cart
  end

  def add_item
    product_id = params[:product_id]
    quantity = params[:quantity] || 1

    respond_to do |format|
      if @cart.add_product(product_id, quantity)
        format.html { redirect_back fallback_location: products_path, notice: "Item added to cart." }
        format.json { render json: { status: "success", cart_count: @cart.cart_items.sum(:quantity) }, status: :ok }
      else
        format.html { redirect_back fallback_location: products_path, alert: "Could not add item to cart." }
        format.json { render json: { status: "error", message: "Could not add item to cart" }, status: :unprocessable_entity }
      end
    end
  end

  def remove_item
    product_id = params[:product_id]
    @cart.remove_product(product_id)

    respond_to do |format|
      format.html { redirect_back fallback_location: cart_path, notice: "Item removed from cart." }
      format.json { render json: { status: "success", cart_count: @cart.cart_items.sum(:quantity) }, status: :ok }
    end
  end

  def update_quantity
    product_id = params[:product_id]
    quantity = params[:quantity]

    @cart.update_quantity(product_id, quantity)

    respond_to do |format|
      format.html { redirect_back fallback_location: cart_path, notice: "Cart updated." }
      format.json { render json: { status: "success", cart_count: @cart.cart_items.sum(:quantity), cart_total: @cart.total }, status: :ok }
    end
  end

  def clear
    @cart.clear

    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Cart cleared." }
      format.json { render json: { status: "success", cart_count: 0 }, status: :ok }
    end
  end

  private

  def set_cart
    @cart = current_user.ensure_cart
  end
end
