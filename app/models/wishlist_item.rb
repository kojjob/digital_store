# frozen_string_literal: true

# WishlistItem model
#
# Represents a product that a user has added to their wishlist.
# This follows domain-driven design by being part of the shopping domain.
class WishlistItem < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :product

  # Validations - we're using a looser validation without uniqueness constraint
  # since we don't know the exact structure of the existing table
  validates :user_id, presence: true
  validates :product_id, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Class method to add product to wishlist
  def self.add_to_wishlist(user, product, notes = nil)
    where(user: user, product: product).first_or_create do |item|
      item.notes = notes if item.respond_to?(:notes)
    end
  end

  # Class method to remove product from wishlist
  def self.remove_from_wishlist(user, product)
    where(user: user, product: product).destroy_all
  end

  # Class method to check if product is in wishlist
  def self.in_wishlist?(user, product)
    exists?(user: user, product: product)
  end

  # Class method to get wishlist count for user
  def self.count_for_user(user)
    where(user: user).count
  end
end
