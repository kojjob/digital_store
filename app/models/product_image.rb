# frozen_string_literal: true

# ProductImage model
#
# Represents an image associated with a product.
# This follows domain-driven design by being part of the product domain.
class ProductImage < ApplicationRecord
  # Associations
  belongs_to :product
  has_one_attached :image

  # Validations
  validates :product_id, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(position: :asc) }

  # Check if image is attached
  def has_image?
    image.attached?
  end

  # Get safe alt text
  def safe_alt_text
    alt_text.presence || "#{product.name} image"
  end
end
