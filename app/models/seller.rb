# frozen_string_literal: true

# Seller model
#
# Represents a seller in the digital marketplace.
# This follows domain-driven design by being part of the marketplace domain.
class Seller < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :orders, through: :products
  has_one_attached :business_logo
  has_one_attached :verification_document
  has_one_attached :banner

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :business_name, presence: true, length: { minimum: 3, maximum: 100 }, allow_nil: true

  # Scopes
  scope :verified, -> { where(verified: true) }

  # Calculate total sales amount
  def total_sales
    orders.sum(:total_amount)
  end

  # Calculate total number of orders
  def total_orders
    orders.count
  end

  # Calculate total number of customers
  def total_customers
    orders.select(:user_id).distinct.count
  end

  # Check if seller is verified
  def verified?
    verified
  end

  # Format store name or fallback to business name
  def store_name
    business_name.presence || "#{user.first_name}'s Store"
  end

  # Calculate average rating across all products
  def average_rating
    product_ids = products.pluck(:id)
    Review.where(product_id: product_ids).average(:rating).to_f.round(1)
  end

  # Calculate response rate based on answered product questions
  def response_rate
    total = products.joins(:product_questions).count
    answered = products.joins(:product_questions).where.not(product_questions: { answered_at: nil }).count

    total > 0 ? (answered.to_f / total * 100).round : 0
  end
end
