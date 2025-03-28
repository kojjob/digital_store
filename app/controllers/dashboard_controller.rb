# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard_presenter

  # GET /dashboard
  def index
    # Set instance variables for the view using the presenter
    @last_login = @presenter.last_login
    @new_notifications = @presenter.new_notifications_count

    if current_user.seller?
      prepare_seller_dashboard
    else
      prepare_buyer_dashboard
    end

    # Common dashboard data
    @recent_activities = @presenter.recent_activities
    @action_items = @presenter.action_items
    @recent_reviews = @presenter.recent_reviews
  end

  # GET /dashboard/schedule
  def schedule
    # Will be implemented in the future
    render :schedule
  end

  private

  # Set up the dashboard presenter
  def set_dashboard_presenter
    timeframe = params[:timeframe] || :month
    @presenter = DashboardPresenter.new(current_user, timeframe: timeframe)
  end

  # Prepare data for seller dashboard
  def prepare_seller_dashboard
    stats = @presenter.seller_stats

    @total_revenue = stats[:total_revenue]
    @revenue_change = stats[:revenue_change]
    @total_orders = stats[:total_orders]
    @orders_change = stats[:orders_change]
    @total_customers = stats[:total_customers]
    @customers_change = stats[:customers_change]
    @total_products = stats[:total_products]
    @products_change = stats[:products_change]

    @recent_orders = @presenter.recent_orders
  end

  # Prepare data for buyer dashboard
  def prepare_buyer_dashboard
    @recent_purchases = @presenter.recent_purchases
    @wishlist_items = @presenter.wishlist_items
    @recommended_products = @presenter.recommended_products
  end
end
