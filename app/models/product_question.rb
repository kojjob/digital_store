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
end
