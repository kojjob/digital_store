# frozen_string_literal: true

# DashboardPresenter
#
# Presenter class for the dashboard view.
# Encapsulates data preparation logic for the dashboard.
class DashboardPresenter
  attr_reader :user, :timeframe

  def initialize(user, timeframe: :month)
    @user = user
    @timeframe = timeframe.to_sym
  end

  # Get the user's last login timestamp
  def last_login
    # This would typically come from a real authentication system
    user.try(:last_sign_in_at) || Time.current - 3.days
  end

  # Count of new notifications for the user
  def new_notifications_count
    # This would typically come from a notifications system
    rand(0..5)
  end

  # Action items for the user's to-do list
  def action_items
    if user.seller?
      seller_action_items
    else
      buyer_action_items
    end
  end

  # Recent activities for the activity feed
  def recent_activities
    # This would typically come from an activities system
    []
  end

  # Recent reviews to display
  def recent_reviews
    # This would typically come from a reviews system
    []
  end

  # Get statistics for a seller's dashboard
  def seller_stats
    # This would typically calculate real statistics from database
    {
      total_revenue: rand(500.0..10000.0).round(2),
      revenue_change: rand(-10.0..30.0).round(1),
      total_orders: rand(10..500),
      orders_change: rand(-5.0..20.0).round(1),
      total_customers: rand(5..200),
      customers_change: rand(-5.0..15.0).round(1),
      total_products: user.seller? && user.seller.products.any? ? user.seller.products.count : rand(1..20),
      products_change: rand(-5.0..15.0).round(1)
    }
  end

  # Get recent orders for a seller
  def recent_orders
    if user.seller?
      # In a real app, you'd get this from the database
      []
    else
      []
    end
  end

  # Get recent purchases for a buyer
  def recent_purchases
    # In a real app, you'd get this from the database
    []
  end

  # Get wishlist items for a buyer
  def wishlist_items
    # In a real app, you'd get this from the database
    []
  end

  # Get recommended products for a buyer
  def recommended_products
    # In a real app, you'd get this from the database
    []
  end

  private

  # Generate sample action items for a seller
  def seller_action_items
    [
      {
        id: 1,
        title: "Complete Your Profile",
        description: "Add more information to your seller profile to attract more customers.",
        category: "profile",
        priority: "high",
        due_date: Date.today + 2.days,
        action_url: "/sellers/edit",
        action_text: "Update Profile"
      },
      {
        id: 2,
        title: "Add Product Images",
        description: "Products with images sell 2x better. Upload images for your new products.",
        category: "product",
        priority: "medium",
        due_date: Date.today + 5.days,
        action_url: "/sellers/products",
        action_text: "Add Images"
      },
      {
        id: 3,
        title: "Respond to Customer Messages",
        description: "You have 2 unanswered customer inquiries.",
        category: "orders",
        priority: "high",
        due_date: Date.today - 1.day,
        action_url: "/inbox",
        action_text: "View Messages"
      }
    ]
  end

  # Generate sample action items for a buyer
  def buyer_action_items
    [
      {
        id: 1,
        title: "Complete Your Profile",
        description: "Add your preferences to get better product recommendations.",
        category: "profile",
        priority: "medium",
        due_date: Date.today + 3.days,
        action_url: "/users/edit",
        action_text: "Update Profile"
      },
      {
        id: 2,
        title: "Review Recent Purchases",
        description: "Share your experience with the products you recently purchased.",
        category: "review",
        priority: "low",
        due_date: Date.today + 7.days,
        action_url: "/orders?filter=pending_review",
        action_text: "Write Reviews"
      }
    ]
  end
end
