# frozen_string_literal: true

require "ostruct"

class Product < ApplicationRecord
  # Associations
  belongs_to :seller
  belongs_to :category
  has_many :orders, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :product_images, dependent: :destroy
  has_many :product_questions, dependent: :destroy
  has_many_attached :images

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :seller_id, presence: true
  validates :category_id, presence: true

  # Scopes - matching the existing schema based on indexed columns
  scope :active, -> { where(published: true) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_price_asc, -> { order(price: :asc) }
  scope :by_price_desc, -> { order(price: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :by_condition, ->(condition) { where(condition: condition) }
  scope :available_in_ghana, -> { where(available_in_ghana: true) }
  scope :available_in_nigeria, -> { where(available_in_nigeria: true) }

  # Instance methods

  # Calculate average rating from reviews
  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  # Check if product has reviews
  def has_reviews?
    reviews.exists?
  end

  # Get count of reviews
  def reviews_count
    reviews.count
  end

  # Check if product is published
  def published?
    published
  end

  # Check if product is featured
  def featured?
    featured
  end

  # Get current discount percentage if applicable
  def discount_percentage
    return 0 unless discounted_price.present? && discounted_price < price

    ((price - discounted_price) / price * 100).round(0)
  end

  # Check if product has a discount
  def discounted?
    discounted_price.present? && discounted_price < price
  end

  # Check if product is on sale
  def on_sale?
    discounted?
  end

  # Get effective price (discounted or regular)
  def effective_price
    discounted? ? discounted_price : price
  end

  # Get primary image
  def primary_image
    if product_images.exists?
      product_images.first
    elsif images.attached?
      images.first
    else
      nil
    end
  end

  # Get formatted dimensions
  def formatted_dimensions
    dimensions.present? ? dimensions : "N/A"
  end

  # Get formatted weight
  def formatted_weight
    weight.present? ? "#{weight} kg" : "N/A"
  end

  # Get current price (discounted or regular)
  def current_price
    effective_price
  end

  # Get regular price
  def regular_price
    price
  end

  # Check if product is in stock
  def in_stock?
    stock_quantity.nil? || stock_quantity <= 0 || stock_quantity > 0
  end

  # Get stock status text
  def stock_status
    return "Digital Product" if stock_quantity.nil? || stock_quantity <= 0
    return "In Stock" if stock_quantity > 10
    "Low Stock (#{stock_quantity} left)" if stock_quantity <= 10
  end

  # Get a shortened version of the description for display in product brief
  def short_description
    return "" if description.blank?
    description.truncate(200, separator: " ", omission: "...")
  end

  # Get the maximum available quantity that can be purchased
  def max_available_quantity
    return 10 if stock_quantity.nil? || stock_quantity <= 0  # Default for digital products
    stock_quantity  # Physical products limited by actual stock
  end

  # Check if product has variants (different options like size, color, etc.)
  def has_variants?
    # This implementation depends on how variants are structured in your application
    # For now, we'll check if the product has any variant types associated with it
    respond_to?(:variant_types) && variant_types.present?
  end

  # Alias for stock_quantity to maintain compatibility with views
  def stock_count
    stock_quantity
  end

  # Get product specifications as a collection of name-value pairs
  # This returns a collection of OpenStruct objects with name and value attributes
  # that can be used in the product show view
  def specifications
    specs = []

    # Add basic specifications from product attributes
    specs << OpenStruct.new(name: "Brand", value: brand) if brand.present?
    specs << OpenStruct.new(name: "Condition", value: condition) if condition.present?
    specs << OpenStruct.new(name: "Weight", value: formatted_weight) if weight.present?
    specs << OpenStruct.new(name: "Dimensions", value: formatted_dimensions) if dimensions.present?
    specs << OpenStruct.new(name: "Country of Origin", value: country_of_origin) if country_of_origin.present?
    specs << OpenStruct.new(name: "SKU", value: sku) if sku.present?

    # Return the collection of specifications
    specs
  end
end
