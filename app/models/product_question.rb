class ProductQuestion < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :question, presence: true
  validates :asked_by, presence: true

  scope :answered, -> { where.not(answer: nil) }
  scope :unanswered, -> { where(answer: nil) }

  def answered?
    answer.present?
  end

  # Ransack configuration for searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    [ "answer", "asked_by", "created_at", "id", "product_id", "question", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "product", "user" ]
  end
end
