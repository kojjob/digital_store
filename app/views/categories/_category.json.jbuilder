json.extract! category, :id, :name, :description, :slug, :parent_id, :position, :visible, :created_at, :updated_at
json.url category_url(category, format: :json)
