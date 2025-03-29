# frozen_string_literal: true

module SuperAdmin
  class DashboardController < SuperAdminController
    before_action :set_date_range, only: [ :finance ]

    def index
      # System overview
      @total_users = User.count
      @admin_users = User.where(admin: true).count
      @super_admin_users = User.where(super_admin: true).count
      @active_users = User.where.not(last_sign_in_at: nil).count

      # Store statistics
      @total_products = Product.count
      @digital_products = Product.where(is_digital: true).count
      @physical_products = Product.where(is_digital: false).count

      # Orders and revenue
      @total_orders = Order.count
      @total_revenue = Order.where(status: "paid").sum(:total_amount)
      @download_count = UserActivity.where(activity_type: "download").count

      Rails.logger.debug "Total Users: #{@total_users}"
      Rails.logger.debug "Admin Users: #{@admin_users}"
      Rails.logger.debug "Super Admin Users: #{@super_admin_users}"
      Rails.logger.debug "Active Users: #{@active_users}"
      Rails.logger.debug "Total Products: #{@total_products}"
      Rails.logger.debug "Digital Products: #{@digital_products}"
      Rails.logger.debug "Physical Products: #{@physical_products}"
      Rails.logger.debug "Total Orders: #{@total_orders}"
      Rails.logger.debug "Total Revenue: #{@total_revenue}"
      Rails.logger.debug "Download Count: #{@download_count}"

      # Calculate trends (for the past 30 days vs previous 30 days)
      @user_trend = calculate_trend(User, 30)
      @order_trend = calculate_trend(Order, 30)
      Rails.logger.debug "Order Trend: #{@order_trend}"
      @revenue_trend = calculate_revenue_trend(30)
      Rails.logger.debug "Revenue Trend: #{@revenue_trend}"
      @product_trend = calculate_trend(Product, 30)
      Rails.logger.debug "Product Trend: #{@product_trend}"

      # Recent activities
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_orders = Order.includes(:user, :product).order(created_at: :desc).limit(5)
      @recent_downloads = DownloadLink.includes(:user, :product).order(created_at: :desc).limit(5)
      Rails.logger.debug "Recent Users: #{@recent_users.inspect}"
      Rails.logger.debug "Recent Orders: #{@recent_orders.inspect}"
      Rails.logger.debug "Recent Downloads: #{@recent_downloads.inspect}"

      # Chart data for the past 6 months
      @chart_months = []
      @user_data = []
      @order_data = []
      @revenue_data = []

      6.times do |i|
        month_start = i.months.ago.beginning_of_month
        month_end = i.months.ago.end_of_month
        month_name = i.months.ago.strftime("%b %Y")

        @chart_months.unshift(month_name)
        @user_data.unshift(User.where(created_at: month_start..month_end).count)
        @order_data.unshift(Order.where(created_at: month_start..month_end).count)
        @revenue_data.unshift(Order.where(status: "paid", created_at: month_start..month_end).sum(:total_amount).to_f)
      end
      Rails.logger.debug "Chart Months: #{@chart_months.inspect}"
      Rails.logger.debug "User Data: #{@user_data.inspect}"
      Rails.logger.debug "Order Data: #{@order_data.inspect}"
      Rails.logger.debug "Revenue Data: #{@revenue_data.inspect}"
    end

    def finance
      # Get all users who have sales or purchases
      @sellers = User.joins(:seller).distinct
      @buyers = User.joins(:orders).distinct

      # Get sales by seller
      @seller_stats = @sellers.map do |user|
        seller_id = user.seller.id
        total_sales = Order.joins(:product).where(products: { seller_id: seller_id }, status: "paid").count
        total_revenue = Order.joins(:product).where(products: { seller_id: seller_id }, status: "paid").sum(:total_amount)
        commission = total_revenue * (user.seller.commission_rate || 0.15) / 100
        net_revenue = total_revenue - commission

        {
          user: user,
          total_sales: total_sales,
          total_revenue: total_revenue,
          commission: commission,
          net_revenue: net_revenue
        }
      end.sort_by { |stats| stats[:total_revenue] }.reverse

      # Get purchases by buyer
      @buyer_stats = @buyers.map do |user|
        orders = Order.where(user_id: user.id, status: "paid")
        total_purchases = orders.count
        total_spent = orders.sum(:total_amount)
        digital_purchases = orders.joins(:product).where(products: { is_digital: true }).count
        physical_purchases = orders.joins(:product).where(products: { is_digital: false }).count

        {
          user: user,
          total_purchases: total_purchases,
          total_spent: total_spent,
          digital_purchases: digital_purchases,
          physical_purchases: physical_purchases
        }
      end.sort_by { |stats| stats[:total_spent] }.reverse

      # Calculate platform metrics
      @total_platform_revenue = Order.where(status: "paid").sum(:total_amount)
      @total_commission = @seller_stats.sum { |stats| stats[:commission] }
      @total_net_revenue_to_sellers = @seller_stats.sum { |stats| stats[:net_revenue] }

      # Time-based metrics
      @monthly_revenue = {}
      @monthly_orders = {}

      # Get data for the last 12 months
      12.times do |i|
        month_start = i.months.ago.beginning_of_month
        month_end = i.months.ago.end_of_month
        month_name = i.months.ago.strftime("%b %Y")

        @monthly_revenue[month_name] = Order.where(status: "paid")
                                            .where(created_at: month_start..month_end)
                                            .sum(:total_amount)

        @monthly_orders[month_name] = Order.where(status: "paid")
                                          .where(created_at: month_start..month_end)
                                          .count
      end

      # Sort by date (reverse the keys to get chronological order)
      @monthly_revenue = @monthly_revenue.to_a.reverse.to_h
      @monthly_orders = @monthly_orders.to_a.reverse.to_h

      # Products breakdown
      @top_products = Product.joins(:orders)
                            .where(orders: { status: "paid" })
                            .group(:id, :name)
                            .select("products.id, products.name, COUNT(orders.id) as orders_count, SUM(orders.total_amount) as revenue")
                            .order("revenue DESC")
                            .limit(10)

      # Order status breakdown
      @order_status_counts = Order.group(:status).count
    end

    def system
      # System health
      @rails_version = Rails.version
      @ruby_version = RUBY_VERSION
      @database_adapter = ActiveRecord::Base.connection.adapter_name
      @database_version = ActiveRecord::Base.connection.select_value("SELECT version()")

      # Database tables and counts
      @table_statistics = ActiveRecord::Base.connection.tables.map do |table|
        count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table}")
        { table: table, count: count }
      end

      # Storage info
      @storage_info = {
        active_storage: ActiveStorage::Blob.sum(:byte_size)
      }

      # Background job info
      @job_counts = {
        enqueued: 0, # Replace with actual queue metrics in production
        processed: 0,
        failed: 0
      }

      # Server load
      @server_load = {
        cpu: 0, # These would be implemented with actual monitoring
        memory: 0,
        disk: 0
      }
    end

    private

    def set_date_range
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 1.year.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    end

    def calculate_trend(model, days)
      current_period = (days.days.ago.to_date..Date.today).to_a
      previous_period = ((days*2).days.ago.to_date..(days+1).days.ago.to_date).to_a

      current_count = model.where(created_at: current_period).count
      previous_count = model.where(created_at: previous_period).count

      if previous_count.zero?
        return current_count.positive? ? 100 : 0
      end

      percentage_change = ((current_count - previous_count).to_f / previous_count) * 100
      percentage_change.round(1)
    end

    def calculate_revenue_trend(days)
      current_period = (days.days.ago.to_date..Date.today).to_a
      previous_period = ((days*2).days.ago.to_date..(days+1).days.ago.to_date).to_a

      current_revenue = Order.where(status: "paid", created_at: current_period).sum(:total_amount)
      previous_revenue = Order.where(status: "paid", created_at: previous_period).sum(:total_amount)

      if previous_revenue.zero?
        return current_revenue.positive? ? 100 : 0
      end

      percentage_change = ((current_revenue - previous_revenue).to_f / previous_revenue) * 100
      percentage_change.round(1)
    end
  end
end
