# frozen_string_literal: true

# Review model
#
# Represents a review of a product by a user.
# This follows domain-driven design by being part of the customer feedback domain.
class Review < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :product

  # Validations
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :with_rating, ->(rating) { where(rating: rating) }
  scope :with_high_rating, -> { where("rating >= ?", 4) }
  scope :with_low_rating, -> { where("rating <= ?", 2) }
  scope :published, -> { where(published: true) }

  # Helper methods
  def self.average_rating_for_product(product_id)
    where(product_id: product_id).average(:rating).to_f.round(1)
  end

  def self.rating_distribution_for_product(product_id)
    where(product_id: product_id).group(:rating).count
  end

  def user_name
    user.full_name
  end

  # Generate a title for the review based on rating
  def title
    case rating
    when 5
      "Excellent Product"
    when 4
      "Very Good Product"
    when 3
      "Average Product"
    when 2
      "Below Average Product"
    when 1
      "Poor Product"
    else
      "Review"
    end
  end

  # Check if the reviewer has purchased the product
  # Returns true if the user has a completed order for this product
  def verified_purchase?
    user.orders.completed.where(product_id: product_id).exists?
  end
end
