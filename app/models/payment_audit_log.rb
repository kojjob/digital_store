# frozen_string_literal: true

# Model to track all payment-related events for audit and security purposes
class PaymentAuditLog < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :order

  # Validations
  validates :event_type, presence: true
  validates :payment_processor, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Enums
  enum :event_type, {
    payment_initiated: 'payment_initiated',
    payment_pending: 'payment_pending',
    payment_successful: 'payment_successful',
    payment_failed: 'payment_failed',
    refund_initiated: 'refund_initiated',
    refund_successful: 'refund_successful',
    refund_failed: 'refund_failed',
    webhook_received: 'webhook_received',
    signature_invalid: 'signature_invalid'
  }

  # Scopes
  scope :successful_payments, -> { where(event_type: 'payment_successful') }
  scope :failed_payments, -> { where(event_type: 'payment_failed') }
  scope :by_processor, ->(processor) { where(payment_processor: processor) }
  scope :recent, -> { order(created_at: :desc) }

  # Serialize the metadata JSON
  serialize :metadata, coder: JSON

  # Methods to parse and analyze metadata
  def metadata_hash
    return {} if metadata.blank?
    
    begin
      metadata.is_a?(Hash) ? metadata : JSON.parse(metadata)
    rescue JSON::ParserError => e
      Rails.logger.error("Error parsing payment audit log metadata: #{e.message}")
      {}
    end
  end

  # Return a formatted version of the event
  def event_description
    case event_type
    when 'payment_successful'
      "Payment of #{ActionController::Base.helpers.number_to_currency(amount)} via #{payment_processor.titleize} was successful"
    when 'payment_failed'
      "Payment of #{ActionController::Base.helpers.number_to_currency(amount)} via #{payment_processor.titleize} failed"
    when 'webhook_received'
      "Webhook received from #{payment_processor.titleize}"
    else
      "#{event_type.humanize} via #{payment_processor.titleize}"
    end
  end
end
