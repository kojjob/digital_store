class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :restrict_with_error
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # Default values for icon properties
  def icon_name
    self[:icon_name] || default_icon_for_category
  end

  def icon_color
    self[:icon_color] || "blue"
  end

  # Get all categories for selection, excluding this one
  def self.selectable_parents(excluding_id = nil)
    scope = Category.order(:name)
    scope = scope.where.not(id: excluding_id) if excluding_id.present?
    scope
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end

  def default_icon_for_category
    # Map common category names to appropriate icons
    case name.downcase
    when /book|ebook|guide|manual/
      "book"
    when /code|program|development|software|app/
      "code"
    when /template|theme|design/
      "template"
    when /icon|symbol|logo/
      "star"
    when /image|photo|picture|graphic/
      "image"
    when /font|type|typography/
      "font"
    else
      "category" # Default fallback
    end
  end
end
