class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show ]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    # Ensure the user can only view their own orders
    unless current_user.admin? || @order.user_id == current_user.id || (current_user.seller? && @order.seller_id == current_user.seller.id)
      redirect_to orders_path, alert: "You don't have permission to view this order."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end
end
