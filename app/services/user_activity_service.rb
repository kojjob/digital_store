# frozen_string_literal: true

# UserActivityService
#
# Service class to manage and track user activity across the application.
# This follows the Service Object pattern which is common in Domain-Driven Design
# to encapsulate business operations that don't naturally fit into a single entity.
class UserActivityService
  # Activity types with their default properties
  ACTIVITY_TYPES = {
    purchase: { icon: "cart", color: "green" },
    review: { icon: "star", color: "amber" },
    wishlist: { icon: "heart", color: "red" },
    payment: { icon: "lightning", color: "blue" },
    profile_update: { icon: "user", color: "indigo" },
    product_view: { icon: "search", color: "gray" },
    login: { icon: "key", color: "blue" },
    order_status: { icon: "refresh", color: "green" },
    promotion: { icon: "notification", color: "purple" },
    seller_update: { icon: "store", color: "purple" }
  }.freeze

  # Record a new activity for a user
  #
  # @param user [User] the user to record activity for
  # @param activity_type [Symbol] the type of activity
  # @param title [String] activity title
  # @param description [String, nil] activity description
  # @param reference [ActiveRecord::Base, nil] associated record
  # @return [UserActivity] the created activity record
  def self.record(user, activity_type, title:, description: nil, reference: nil)
    activity_properties = ACTIVITY_TYPES[activity_type.to_sym] || { icon: "template", color: "gray" }

    # In a real app, we would have a UserActivity model
    # This is a simplified implementation for our enhancement
    activity = UserActivity.new(
      user: user,
      activity_type: activity_type.to_s,
      title: title,
      description: description,
      icon: activity_properties[:icon],
      color: activity_properties[:color]
    )

    # Set polymorphic association if reference is provided
    if reference.present?
      activity.reference = reference
    end

    activity.save
    activity
  end

  # Get recent activities for a user
  #
  # @param user [User] the user to get activities for
  # @param limit [Integer] maximum number of activities to return
  # @return [ActiveRecord::Relation] collection of activities
  def self.recent_for_user(user, limit: 10)
    user.activities.order(created_at: :desc).limit(limit)
  end

  # Get activity feed for a user (including relevant activities from others)
  #
  # @param user [User] the user to get activity feed for
  # @param limit [Integer] maximum number of activities to return
  # @return [ActiveRecord::Relation] collection of activities
  def self.feed_for_user(user, limit: 20)
    if user.seller?
      # Include activities related to seller's products
      UserActivity.where(user_id: user.id)
                 .or(UserActivity.where(reference_type: "Product", reference_id: user.seller.product_ids))
                 .order(created_at: :desc)
                 .limit(limit)
    else
      # For buyers, primarily show their own activities and some global ones
      UserActivity.where(user_id: user.id)
                 .order(created_at: :desc)
                 .limit(limit)
    end
  end

  # Format activity for display in the dashboard
  #
  # @param activity [UserActivity] the activity to format
  # @return [Hash] formatted activity for view consumption
  def self.format_for_dashboard(activity)
    {
      id: activity.id,
      icon: activity.icon,
      color: activity.color,
      title: activity.title,
      description: activity.description,
      created_at: activity.created_at,
      reference_type: activity.reference_type,
      reference_id: activity.reference_id
    }
  end
end

# Example of how you might define a UserActivity model
# This is a placeholder - in a real application, you would generate a proper model
class UserActivity < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  # Validations
  validates :activity_type, :title, presence: true
  validates :icon, :color, presence: true

  # Scopes
  scope :by_type, ->(type) { where(activity_type: type) }
  scope :with_reference, -> { where.not(reference_type: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods to make creation easier
  class << self
    ACTIVITY_TYPES.each do |type, properties|
      define_method "record_#{type}" do |user, title:, description: nil, reference: nil|
        create(
          user: user,
          activity_type: type.to_s,
          title: title,
          description: description,
          icon: properties[:icon],
          color: properties[:color],
          reference: reference
        )
      end
    end
  end
end
