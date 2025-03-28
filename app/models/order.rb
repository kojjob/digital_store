class Order < ApplicationRecord
  belongs_to :user
  
  validates :status, presence: true, inclusion: { in: %w[pending processing paid completed cancelled refunded] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  # Fields for payment tracking
  validates :payment_processor, inclusion: { in: %w[stripe momo], allow_nil: true }
  validates :payment_status, inclusion: { in: %w[pending processing paid failed refunded], allow_nil: true }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }
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
