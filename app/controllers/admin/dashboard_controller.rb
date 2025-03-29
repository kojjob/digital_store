# frozen_string_literal: true

module Admin
  class DashboardController < AdminController
    def index
      # Recent orders
      @recent_orders = Order.includes(:user, :product)
                           .order(created_at: :desc)
                           .limit(5)

      # Recent downloads
      @recent_downloads = DownloadLink.includes(:user, :product, :order)
                                     .order(created_at: :desc)
                                     .limit(5)

      # Payment statistics
      @total_revenue = Order.where(status: "paid").sum(:total_amount)
      @orders_today = Order.where("DATE(created_at) = ?", Date.today).count
      @orders_this_week = Order.where("created_at >= ?", 1.week.ago).count
      @orders_this_month = Order.where("created_at >= ?", 1.month.ago).count

      # Download statistics
      @downloads_today = UserActivity.where(activity_type: "download")
                                    .where("DATE(created_at) = ?", Date.today)
                                    .count
      @downloads_this_week = UserActivity.where(activity_type: "download")
                                        .where("created_at >= ?", 1.week.ago)
                                        .count
      @downloads_this_month = UserActivity.where(activity_type: "download")
                                         .where("created_at >= ?", 1.month.ago)
                                         .count

      # Payment method breakdown
      @payment_methods = Order.group(:payment_processor).count

      # Popular products
      @popular_products = Product.joins(:orders)
                                .where(orders: { status: "paid" })
                                .group("products.id")
                                .order("COUNT(orders.id) DESC")
                                .limit(5)
                                .select("products.*, COUNT(orders.id) as sales_count")

      # Expiring download links
      @expiring_links = DownloadLink.active
                                   .where("expires_at BETWEEN ? AND ?", Time.current, 3.days.from_now)
                                   .includes(:user, :product)
                                   .order("expires_at ASC")
                                   .limit(5)
    end

    def analytics
      # Date range filter
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      # Sales over time
      @daily_sales = Order.where(status: "paid")
                         .where("created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day)
                         .group("DATE(created_at)")
                         .order("DATE(created_at)")
                         .sum(:total_amount)

      # Downloads over time
      @daily_downloads = UserActivity.where(activity_type: "download")
                                    .where("created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day)
                                    .group("DATE(created_at)")
                                    .order("DATE(created_at)")
                                    .count

      # Product category analysis
      @category_sales = Order.joins(product: :category)
                            .where(status: "paid")
                            .where("orders.created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day)
                            .group("categories.name")
                            .sum(:total_amount)

      # Payment method analysis
      @payment_method_breakdown = Order.where(status: "paid")
                                      .where("created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day)
                                      .group(:payment_processor)
                                      .count

      # Geographic sales analysis (if available)
      if User.column_names.include?("country")
        @country_sales = Order.joins(:user)
                             .where(status: "paid")
                             .where("orders.created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day)
                             .group("users.country")
                             .sum(:total_amount)
      end
    end
  end
end
