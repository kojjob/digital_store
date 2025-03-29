# frozen_string_literal: true

module SuperAdmin
  class DashboardController < SuperAdminController
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

      # Recent activities
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_orders = Order.includes(:user, :product).order(created_at: :desc).limit(5)
      @recent_downloads = DownloadLink.includes(:user, :product).order(created_at: :desc).limit(5)
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
  end
end
