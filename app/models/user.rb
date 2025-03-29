# frozen_string_literal: true

# User model
#
# Represents a user in the digital store system.
# This is a core entity in our domain model.
class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Get a safe list of tables that exist
  def self.existing_tables
    @existing_tables ||= begin
      ActiveRecord::Base.connection.tables
    rescue
      []
    end
  end

  # Associations - use if to check table existence to avoid loading errors
  has_one :seller, dependent: :destroy if existing_tables.include?("sellers")
  has_one :cart, dependent: :destroy if existing_tables.include?("carts")
  has_many :orders, dependent: :destroy if existing_tables.include?("orders")
  has_many :reviews, dependent: :destroy if existing_tables.include?("reviews")
  has_many :action_items, dependent: :destroy if existing_tables.include?("action_items")
  has_many :activities, class_name: "UserActivity", dependent: :destroy if existing_tables.include?("user_activities")
  has_many :notifications, dependent: :destroy if existing_tables.include?("notifications")
  has_many :wishlist_items, dependent: :destroy if existing_tables.include?("wishlist_items")
  has_many :download_links, dependent: :destroy if existing_tables.include?("download_links")
  has_one_attached :profile_picture

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, length: { maximum: 50 }

  # Scopes
  scope :sellers, -> { joins(:seller) }
  scope :buyers, -> { where.not(id: Seller.select(:user_id)) }
  scope :active, -> { where(active: true) }

  # Virtual attribute for removing profile picture
  attr_accessor :remove_profile_picture

  # Callbacks
  before_save :handle_profile_picture_removal
  after_create :create_default_action_items

  # Returns user's full name or email if name not available
  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    else
      email.split("@").first
    end
  end

  # Check if user is a seller
  def seller?
    begin
      # Skip seller check if we're running migrations
      return false if defined?(Rake) && Rake.application.top_level_tasks.include?("db:migrate")

      # Skip seller check if the table doesn't exist
      tables = ActiveRecord::Base.connection.tables rescue []
      return false unless tables.include?("sellers")

      # Check if seller association exists
      seller.present?
    rescue => e
      # Log error and return false for any failure
      Rails.logger.error("Error checking seller status: #{e.message}")
      false
    end
  end

  # Check if user is an admin
  def admin?
    admin == true || super_admin == true
  end

  # Check if user is a super admin
  def super_admin?
    super_admin == true
  end

  # Check if user is a buyer (not a seller)
  def buyer?
    !seller?
  end

  # Check if user is active
  def active?
    # Use the active database column if present, otherwise fall back to the login-based check
    if has_attribute?(:active)
      active == true
    else
      last_sign_in_at.present? || created_at > 30.days.ago
    end
  end

  # Create a seller profile for this user
  def become_seller(seller_params)
    create_seller(seller_params)
  end

  # Record user activity
  def record_activity(activity_type, title:, description: nil, reference: nil)
    UserActivityService.record(self, activity_type,
                              title: title,
                              description: description,
                              reference: reference)
  end

  # Get recommended products for this user
  def recommended_products(limit: 6)
    # In a real application, this would use a recommendation algorithm
    # For simplicity, we'll return recent products
    Product.active.order(created_at: :desc).limit(limit)
  end

  # Check if user has a profile picture
  def has_profile_picture?
    profile_picture.attached?
  end

  # Get or create a cart for this user
  def ensure_cart
    cart || create_cart
  end

  # Return phone number (placeholder method)
  # This method is added to prevent NoMethodError in views
  def phone_number
    nil
  end

  private

  # Handle profile picture removal if requested
  def handle_profile_picture_removal
    if remove_profile_picture == "1" || remove_profile_picture == true
      profile_picture.purge if profile_picture.attached?
    end
  end

  # Create default action items for a new user
  def create_default_action_items
    # Skip default action items for super admin
    return if super_admin?

    begin
      action_items.create(
        title: "Complete your profile",
        description: "Add your profile picture and complete your bio to help others know you better.",
        priority: :medium,
        due_date: 7.days.from_now
      )

      action_items.create(
        title: "Browse products",
        description: "Check out our selection of digital products matching your interests.",
        priority: :low,
        due_date: 3.days.from_now
      )
    rescue => e
      Rails.logger.error("Error creating default action items: #{e.message}")
    end
  end
end
