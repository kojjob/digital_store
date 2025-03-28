# frozen_string_literal: true

# ActionItem model
#
# Represents a task or todo item for a user in the digital store.
# This is part of our domain model following DDD principles.
class ActionItem < ApplicationRecord
  # Constants for priority
  LOW = 0
  MEDIUM = 1
  HIGH = 2

  # Associations
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :priority, presence: true, inclusion: { in: [ LOW, MEDIUM, HIGH ] }

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :overdue, -> { pending.where("due_date < ?", Date.current) }
  scope :upcoming, -> { pending.where("due_date >= ?", Date.current) }
  scope :high_priority, -> { where(priority: HIGH) }
  scope :medium_priority, -> { where(priority: MEDIUM) }
  scope :low_priority, -> { where(priority: LOW) }

  # Callbacks
  before_save :set_default_due_date, if: -> { due_date.blank? }

  # Set default due date to 7 days from now if not specified
  def set_default_due_date
    self.due_date = 7.days.from_now
  end

  # Check if item is overdue
  def overdue?
    pending? && due_date.present? && due_date < Date.current
  end

  # Check if item is due soon (within 24 hours)
  def due_soon?
    pending? && due_date.present? && due_date <= 1.day.from_now && due_date >= Date.current
  end

  # Check if item is pending
  def pending?
    !completed
  end

  # Get priority label
  def priority_label
    case priority
    when HIGH
      "High"
    when MEDIUM
      "Medium"
    when LOW
      "Low"
    else
      "Unknown"
    end
  end

  # Mark as completed
  def complete!
    update(completed: true)
  end

  # Mark as pending
  def reopen!
    update(completed: false)
  end
end
