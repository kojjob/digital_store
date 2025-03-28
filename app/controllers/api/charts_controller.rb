# frozen_string_literal: true

module Api
  # ChartsController
  #
  # Controller for handling API requests for chart data.
  # This follows RESTful API design principles and provides
  # endpoints for the JavaScript charting libraries to consume.
  class ChartsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller, except: [ :product_trends ]

    # GET /api/charts/revenue
    def revenue
      period = params[:period].to_sym if %w[week month year].include?(params[:period])
      period ||= :month

      chart_data = ChartsService.revenue_chart_data(current_user.seller, period: period)
      render json: chart_data
    end

    # GET /api/charts/orders
    def orders
      period = params[:period].to_sym if %w[week month year].include?(params[:period])
      period ||= :month

      chart_data = ChartsService.orders_chart_data(current_user.seller, period: period)
      render json: chart_data
    end

    # GET /api/charts/product_performance
    def product_performance
      limit = (params[:limit] || 5).to_i

      chart_data = ChartsService.product_performance_data(current_user.seller, limit: limit)
      render json: chart_data
    end

    # GET /api/charts/customer_acquisition
    def customer_acquisition
      months = (params[:months] || 6).to_i

      chart_data = ChartsService.customer_acquisition_data(current_user.seller, months: months)
      render json: chart_data
    end

    # GET /api/charts/product_trends
    # Available to both sellers and buyers
    def product_trends
      category = params[:category]
      limit = (params[:limit] || 5).to_i

      # Logic to fetch trending products
      # This is a simplified implementation
      products = Product.active
                       .where(category: category) if category.present?

      products = products || Product.active
      products = products.order(views_count: :desc).limit(limit)

      chart_data = {
        labels: products.map(&:name),
        datasets: [
          {
            label: "Views",
            data: products.map(&:views_count),
            backgroundColor: "#F59E0B",
            borderColor: "#D97706",
            borderWidth: 1
          }
        ]
      }

      render json: chart_data
    end

    private

    # Ensure the current user is a seller
    def ensure_seller
      unless current_user.seller?
        render json: { error: "Access denied. Seller account required." }, status: :forbidden
      end
    end
  end
end
