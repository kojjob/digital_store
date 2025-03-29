# frozen_string_literal: true

class DownloadLink < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :user
  belongs_to :order, optional: true

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :download_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :download_count, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_defaults, on: :create
  before_validation :generate_token, on: :create

  # Scopes
  scope :active, -> { where(active: true) }
  scope :not_expired, -> { where("expires_at > ?", Time.current) }
  scope :available, -> { active.not_expired.where("download_count < download_limit OR download_limit = 0") }

  # Instance methods

  # Check if the download link is valid and can be used
  def valid_for_download?
    active? && !expired? && !download_limit_reached?
  end

  # Check if the download link has expired
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  # Check if the download count has reached the limit
  def download_limit_reached?
    download_limit.positive? && download_count >= download_limit
  end

  # Increment the download count
  def increment_download_count!
    increment!(:download_count)
  end

  # Deactivate the download link
  def deactivate!
    update(active: false)
  end

  # Generate a new token and reset the download link
  def regenerate!(new_expiry = nil)
    new_expiry ||= 7.days.from_now

    self.token = generate_unique_token
    self.expires_at = new_expiry
    self.download_count = 0
    self.active = true

    save!
  end

  # Return expiration in a human-readable format
  def expiration_in_words
    if expires_at.present?
      if expired?
        "Expired"
      else
        time_diff = ((expires_at - Time.current) / 1.hour).round
        if time_diff < 24
          "Expires in #{time_diff} hours"
        else
          "Expires in #{(time_diff / 24.0).round} days"
        end
      end
    else
      "No expiration"
    end
  end

  private

  # Set default values
  def set_defaults
    self.download_count ||= 0
    self.download_limit ||= 5
    self.active = true if active.nil?
    self.expires_at ||= 7.days.from_now
  end

  # Generate a unique token
  def generate_token
    self.token ||= generate_unique_token
  end

  # Generate a unique token
  def generate_unique_token
    loop do
      token = SecureRandom.urlsafe_base64(16)
      break token unless DownloadLink.exists?(token: token)
    end
  end
end
