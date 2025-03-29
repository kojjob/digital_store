# frozen_string_literal: true

module SuperAdmin
  class SystemController < SuperAdminController
    def index
      # System version info
      @rails_version = Rails.version
      @ruby_version = RUBY_VERSION
      @environment = Rails.env

      # Application status
      @uptime = process_uptime
      @last_deployment = last_deployment_time

      # Database info
      @database_adapter = ActiveRecord::Base.connection.adapter_name
      @database_version = ActiveRecord::Base.connection.select_value("SELECT version()")
      @database_size = database_size

      # Table statistics
      @tables = ActiveRecord::Base.connection.tables.sort.map do |table|
        row_count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table}")
        { name: table, rows: row_count }
      end

      # Active Storage statistics
      @storage_stats = {
        total_blobs: ActiveStorage::Blob.count,
        total_size: ActiveStorage::Blob.sum(:byte_size),
        image_count: ActiveStorage::Blob.where("content_type LIKE 'image/%'").count,
        document_count: ActiveStorage::Blob.where("content_type LIKE 'application/%'").count
      }
    end

    def logs
      # Read the last 1000 lines of the log file based on environment
      log_file = Rails.root.join("log", "#{Rails.env}.log")
      @log_data = if File.exist?(log_file)
                    `tail -n 1000 #{log_file}`
      else
                    "Log file not found"
      end
    end

    def clear_cache
      Rails.cache.clear
      redirect_to super_admin_system_path, notice: "Application cache has been cleared."
    end

    private

    def process_uptime
      # In a real app, you would use a gem like sys-uptime or system commands
      # This is a simplified version
      start_time = File.ctime(Rails.root.join("tmp", "pids", "server.pid")) rescue Time.now
      Time.now - start_time
    end

    def last_deployment_time
      # In a real app, this would be pulled from deployment tools
      # Here, approximating with the application.rb file time
      File.mtime(Rails.root.join("config", "application.rb"))
    end

    def database_size
      # This would depend on the database adapter
      # For PostgreSQL:
      if ActiveRecord::Base.connection.adapter_name.downcase.include?("postgresql")
        db_name = ActiveRecord::Base.connection.current_database
        result = ActiveRecord::Base.connection.select_value(
          "SELECT pg_size_pretty(pg_database_size('#{db_name}'))"
        )
        result || "Unknown"
      else
        "Not available for this database adapter"
      end
    end
  end
end
