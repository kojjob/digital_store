class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :download_links, dependent: :nullify

  validates :status, presence: true, inclusion: { in: %w[pending processing paid completed cancelled refunded] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  # Fields for payment tracking
  validates :payment_processor, inclusion: { in: %w[stripe momo], allow_nil: true }
  validates :payment_status, inclusion: { in: %w[pending processing paid failed refunded], allow_nil: true }

  # Callbacks
  after_update :create_download_link, if: :newly_paid?

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

  # Check if the order is newly paid (changed from pending/processing to paid)
  def newly_paid?
    saved_change_to_status? && status == "paid" &&
      [ "pending", "processing" ].include?(status_before_last_save)
  end

  # Create a download link for this order
  def create_download_link
    return unless product.digital_file.attached?

    # Create a new download link for the user
    download_links.create!(
      user: user,
      product: product,
      expires_at: 30.days.from_now,
      download_limit: 5,
      file_name: product.digital_file.filename.to_s,
      file_size: product.digital_file.byte_size,
      content_type: product.digital_file.content_type
    )
  end
end
