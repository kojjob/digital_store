class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :status, presence: true, inclusion: { in: %w[pending processing completed cancelled refunded] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :recent, -> { order(created_at: :desc) }

  # Methods to simplify status checks
  def pending?
    status == "pending"
  end

  def completed?
    status == "completed"
  end

  def cancelled?
    status == "cancelled"
  end
end
