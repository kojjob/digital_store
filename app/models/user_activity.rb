# frozen_string_literal: true

# UserActivity model
#
# Represents an activity performed by a user in the digital store.
# This is part of the activity tracking domain that follows DDD principles.
class UserActivity < ApplicationRecord
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
  }

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

  # Class methods for creating activities with proper icons and colors
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

    # Generic method for recording any activity
    def record(user, activity_type, title:, description: nil, reference: nil)
      properties = ACTIVITY_TYPES[activity_type.to_sym] || { icon: "template", color: "gray" }

      create(
        user: user,
        activity_type: activity_type.to_s,
        title: title,
        description: description,
        icon: properties[:icon],
        color: properties[:color],
        reference: reference
      )
    end
  end

  # Get formatted timestamp for display
  def formatted_time
    created_at.strftime("%B %d, %Y at %I:%M %p")
  end

  # Get time ago in words
  def time_ago
    ActionView::Helpers::DateHelper.time_ago_in_words(created_at) rescue "some time ago"
  end

  # Format for dashboard display
  def to_dashboard_format
    {
      id: id,
      icon: icon,
      color: color,
      title: title,
      description: description,
      created_at: created_at,
      reference_type: reference_type,
      reference_id: reference_id
    }
  end
end
