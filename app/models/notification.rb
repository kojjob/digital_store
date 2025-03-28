# frozen_string_literal: true

# Notification model
#
# Represents a notification sent to a user in the digital store.
# This follows domain-driven design by being part of the user notification domain.
class Notification < ApplicationRecord
  # Constants for notification types
  TYPES = {
    info: 0,
    success: 1,
    warning: 2,
    error: 3,
    order: 4,
    payment: 5,
    product: 6,
    review: 7,
    system: 8
  }

  # Constants for status
  UNREAD = 0
  READ = 1

  # Associations
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :title, presence: true

  # Scopes based on existing schema
  scope :unread, -> { where(status: UNREAD) }
  scope :read, -> { where(status: READ) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: TYPES[type.to_sym]) if TYPES.key?(type.to_sym) }

  # Helper methods for notification status
  def unread?
    status == UNREAD
  end

  def read?
    status == READ
  end

  # Mark notification as read
  def mark_as_read!
    update(status: READ, read_at: Time.current)
  end

  # Get notification type name
  def type_name
    TYPES.key(notification_type)&.to_s || "unknown"
  end

  # Class methods for creating notifications
  class << self
    # Create a system notification
    def create_system_notification(user, title, message)
      create(
        user: user,
        title: title,
        message: message,
        notification_type: TYPES[:system],
        status: UNREAD
      )
    end

    # Create an order notification
    def create_order_notification(user, order, title, message)
      create(
        user: user,
        title: title,
        message: message,
        notification_type: TYPES[:order],
        notifiable: order,
        status: UNREAD
      )
    end

    # Create a product notification
    def create_product_notification(user, product, title, message)
      create(
        user: user,
        title: title,
        message: message,
        notification_type: TYPES[:product],
        notifiable: product,
        status: UNREAD
      )
    end
  end
end
