# frozen_string_literal: true

# DashboardPresenter
#
# Implements the presenter pattern to encapsulate dashboard view-related
# logic and data preparation. This follows domain-driven design by separating
# the presentation logic from the controllers and models.
#
# The presenter acts as an adapter between the domain model and the view,
# providing a cleaner interface for the dashboard view to consume.
class DashboardPresenter
  attr_reader :user, :timeframe

  # Initialize a new dashboard presenter
  #
  # @param user [User] the current user
  # @param timeframe [Symbol, String] the reporting timeframe (:week, :month, :year)
  def initialize(user, timeframe: :month)
    @user = user
    @timeframe = timeframe.to_sym
  end

  # Get user's last login time
  #
  # @return [DateTime, nil] the last login time or nil if not available
  def last_login
    # Check if last_sign_in_at method exists, otherwise return nil
    if user.respond_to?(:last_sign_in_at)
      user.last_sign_in_at
    else
      # Fallback to created_at as a default value or nil
      user.try(:created_at)
    end
  end

  # Check if user has seller role
  #
  # @return [Boolean] true if user is a seller
  def seller?
    user.seller?
  end

  # Get count of new notifications
  #
  # @return [Integer] the number of unread notifications
  def new_notifications_count
    begin
      # Skip notification checks entirely if we're running migrations
      return 0 if defined?(Rake) && Rake.application.top_level_tasks.include?("db:migrate")

      # Skip notification checks if the table doesn't exist yet
      return 0 unless ActiveRecord::Base.connection.table_exists?("notifications")

      # Make sure the user has notifications
      return 0 unless user.respond_to?(:notifications)

      # Try to count unread notifications
      user.notifications.unread.count
    rescue => e
      # Log error and return 0 for any failure
      Rails.logger.error("Error counting notifications: #{e.message}")
      0
    end
  end

  # Get seller stats if user is a seller
  #
  # @return [Hash] seller statistics including revenue, orders, etc.
  def seller_stats
    return {} unless seller?

    {
      total_revenue: calculate_seller_revenue,
      revenue_change: calculate_revenue_change,
      total_orders: seller_orders.count,
      orders_change: calculate_orders_change,
      total_customers: calculate_unique_customers,
      customers_change: calculate_customers_change,
      total_products: user.seller.products.count,
      products_change: calculate_products_change
    }
  end

  # Get recent orders for a seller
  #
  # @param limit [Integer] the maximum number of orders to return
  # @return [ActiveRecord::Relation] collection of recent orders
  def recent_orders(limit: 5)
    return [] unless seller?

    seller_orders.includes(:user, :product)
                .order(created_at: :desc)
                .limit(limit)
  end

  # Get recent purchases for a buyer
  #
  # @param limit [Integer] the maximum number of purchases to return
  # @return [ActiveRecord::Relation] collection of recent purchases
  def recent_purchases(limit: 5)
    return [] if seller?

    user.orders.includes(:product)
        .order(created_at: :desc)
        .limit(limit)
  end

  # Get wishlist items for a buyer
  #
  # @return [ActiveRecord::Relation] collection of wishlist items
  def wishlist_items
    return [] if seller?

    begin
      # Skip wishlist checks if we're running migrations
      return [] if defined?(Rake) && Rake.application.top_level_tasks.include?("db:migrate")

      # Skip wishlist checks if the table doesn't exist yet
      return [] unless ActiveRecord::Base.connection.table_exists?("wishlist_items")

      # Make sure the user has wishlist_items association
      return [] unless user.respond_to?(:wishlist_items)

      # Try to get wishlist items
      user.wishlist_items.includes(:product)
    rescue => e
      # Log error and return empty array for any failure
      Rails.logger.error("Error getting wishlist items: #{e.message}")
      []
    end
  end

  # Get recommended products for a buyer
  #
  # @param limit [Integer] the maximum number of products to return
  # @return [ActiveRecord::Relation] collection of recommended products
  def recommended_products(limit: 6)
    return [] if seller?

    begin
      # Skip product checks if we're running migrations
      return [] if defined?(Rake) && Rake.application.top_level_tasks.include?("db:migrate")

      # Skip product checks if the table doesn't exist yet
      return [] unless ActiveRecord::Base.connection.table_exists?("products")

      # Verify Product model exists and has necessary scopes/associations
      return [] unless defined?(Product) && Product.respond_to?(:active)

      # In a real app, this would use a recommendation engine
      # For now, just get the latest products
      Product.active
             .includes(:product_images)
             .order(created_at: :desc)
             .limit(limit)
    rescue => e
      # Log error and return empty array for any failure
      Rails.logger.error("Error getting recommended products: #{e.message}")
      []
    end
  end

  # Get recent reviews
  #
  # @param limit [Integer] the maximum number of reviews to return
  # @return [ActiveRecord::Relation] collection of recent reviews
  def recent_reviews(limit: 3)
    begin
      # Skip review checks if we're running migrations
      return [] if defined?(Rake) && Rake.application.top_level_tasks.include?("db:migrate")

      # Skip review checks if the table doesn't exist yet
      return [] unless ActiveRecord::Base.connection.table_exists?("reviews")

      if seller?
        # Verify associations exist
        return [] unless defined?(Review) && defined?(Product)

        # Get reviews for the seller's products
        Review.joins(product: :seller)
              .where(products: { seller_id: user.seller.id })
              .includes(:user, :product)
              .order(created_at: :desc)
              .limit(limit)
      else
        # Make sure the user has reviews association
        return [] unless user.respond_to?(:reviews)

        # Get the user's reviews as a buyer
        user.reviews.includes(:product)
            .order(created_at: :desc)
            .limit(limit)
      end
    rescue => e
      # Log error and return empty array for any failure
      Rails.logger.error("Error getting recent reviews: #{e.message}")
      []
    end
  end

  # Get recent activity items
  #
  # @param limit [Integer] the maximum number of activity items to return
  # @return [Array<Hash>] collection of activity items
  def recent_activities(limit: 5)
    # Note: In a real app, this would likely come from an ActivityLog model
    # This is a simplified example using dummy data

    if seller?
      seller_activities(limit)
    else
      buyer_activities(limit)
    end
  end

  # Get action items
  #
  # @param limit [Integer] the maximum number of action items to return
  # @return [Array<Hash>] collection of action items
  def action_items(limit: 4)
    # Note: In a real app, this would likely come from an ActionItem model
    # This is a simplified example using dummy data

    items = []

    if seller?
      # Seller-specific action items
      items << {
        title: "Update product inventory",
        description: "Review and update your product stock levels.",
        priority: "high",
        due_date: 2.days.from_now
      }

      items << {
        title: "Respond to customer inquiries",
        description: "You have 3 unanswered messages from customers.",
        priority: "high",
        due_date: 1.day.from_now
      }
    end

    # Common action items
    items << {
      title: "Complete your profile",
      description: "Add a profile picture and complete your bio.",
      priority: "medium",
      due_date: 7.days.from_now
    }

    items << {
      title: "Review platform updates",
      description: "Check out the latest features and improvements.",
      priority: "low",
      due_date: 14.days.from_now
    }

    items.first(limit)
  end

  private

  # Get all orders for the seller
  #
  # @return [ActiveRecord::Relation] collection of seller's orders
  def seller_orders
    return [] unless seller?

    Order.joins(product: :seller)
         .where(products: { seller_id: user.seller.id })
  end

  # Calculate total seller revenue
  #
  # @return [Float] total revenue
  def calculate_seller_revenue
    return 0 unless seller?

    seller_orders.sum(:total_amount)
  end

  # Calculate revenue change percentage
  #
  # @return [Float] percentage change in revenue
  def calculate_revenue_change
    return 0 unless seller?

    current_period_revenue = seller_orders.where(created_at: time_period_range).sum(:total_amount)
    previous_period_revenue = seller_orders.where(created_at: previous_time_period_range).sum(:total_amount)

    calculate_percentage_change(current_period_revenue, previous_period_revenue)
  end

  # Calculate orders change percentage
  #
  # @return [Float] percentage change in orders
  def calculate_orders_change
    return 0 unless seller?

    current_period_orders = seller_orders.where(created_at: time_period_range).count
    previous_period_orders = seller_orders.where(created_at: previous_time_period_range).count

    calculate_percentage_change(current_period_orders, previous_period_orders)
  end

  # Calculate unique customers
  #
  # @return [Integer] number of unique customers
  def calculate_unique_customers
    return 0 unless seller?

    seller_orders.select(:user_id).distinct.count
  end

  # Calculate customers change percentage
  #
  # @return [Float] percentage change in customers
  def calculate_customers_change
    return 0 unless seller?

    current_period_customers = seller_orders.where(created_at: time_period_range).select(:user_id).distinct.count
    previous_period_customers = seller_orders.where(created_at: previous_time_period_range).select(:user_id).distinct.count

    calculate_percentage_change(current_period_customers, previous_period_customers)
  end

  # Calculate products change percentage
  #
  # @return [Float] percentage change in products
  def calculate_products_change
    return 0 unless seller?

    current_period_products = user.seller.products.where(created_at: time_period_range).count
    previous_period_products = user.seller.products.where(created_at: previous_time_period_range).count

    calculate_percentage_change(current_period_products, previous_period_products)
  end

  # Generate seller activity items
  #
  # @param limit [Integer] the maximum number of activity items to return
  # @return [Array<Hash>] collection of seller activity items
  def seller_activities(limit)
    [
      {
        icon: "cart",
        color: "green",
        title: "New order received",
        description: "You received an order for Digital Marketing Guide.",
        created_at: 2.hours.ago
      },
      {
        icon: "star",
        color: "amber",
        title: "New product review",
        description: "Your product received a 5-star review.",
        created_at: 1.day.ago
      },
      {
        icon: "lightning",
        color: "blue",
        title: "Payment processed",
        description: "Payment for order #12345 was processed successfully.",
        created_at: 2.days.ago
      },
      {
        icon: "notification",
        color: "purple",
        title: "Promotion approved",
        description: "Your seasonal promotion has been approved.",
        created_at: 3.days.ago
      },
      {
        icon: "user",
        color: "green",
        title: "New customer",
        description: "John Doe made their first purchase from your store.",
        created_at: 4.days.ago
      }
    ].first(limit)
  end

  # Generate buyer activity items
  #
  # @param limit [Integer] the maximum number of activity items to return
  # @return [Array<Hash>] collection of buyer activity items
  def buyer_activities(limit)
    [
      {
        icon: "cart",
        color: "green",
        title: "Purchase completed",
        description: "You purchased Digital Marketing Guide.",
        created_at: 2.hours.ago
      },
      {
        icon: "star",
        color: "amber",
        title: "Review submitted",
        description: "You left a review for SEO Mastery Course.",
        created_at: 1.day.ago
      },
      {
        icon: "heart",
        color: "red",
        title: "Item added to wishlist",
        description: "You added Social Media Templates to your wishlist.",
        created_at: 2.days.ago
      },
      {
        icon: "lightning",
        color: "blue",
        title: "Download completed",
        description: "You downloaded your purchased product.",
        created_at: 3.days.ago
      },
      {
        icon: "user",
        color: "indigo",
        title: "Profile updated",
        description: "You updated your profile information.",
        created_at: 4.days.ago
      }
    ].first(limit)
  end

  # Calculate percentage change
  #
  # @param current_value [Numeric] current period value
  # @param previous_value [Numeric] previous period value
  # @return [Float] percentage change
  def calculate_percentage_change(current_value, previous_value)
    return 0 if previous_value.zero?

    ((current_value - previous_value) / previous_value.to_f) * 100
  end

  # Get time period range based on timeframe
  #
  # @return [Range] date range for the current period
  def time_period_range
    case timeframe
    when :week
      1.week.ago..Time.current
    when :month
      1.month.ago..Time.current
    when :year
      1.year.ago..Time.current
    else
      1.month.ago..Time.current
    end
  end

  # Get previous time period range based on timeframe
  #
  # @return [Range] date range for the previous period
  def previous_time_period_range
    case timeframe
    when :week
      2.weeks.ago..1.week.ago
    when :month
      2.months.ago..1.month.ago
    when :year
      2.years.ago..1.year.ago
    else
      2.months.ago..1.month.ago
    end
  end
end
