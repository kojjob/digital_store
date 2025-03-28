class SearchController < ApplicationController
  def index
    @query = params[:query].to_s.strip
    @format = params[:format] || "html"

    if @query.blank?
      @results = { categories: [], products: [] }
      return handle_response
    end

    # Search with pagination for main results page
    if @format == "html"
      @categories = Category.where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
                            .where(visible: true)
                            .order(:position, :name)
                            .limit(5)

      @products = Product.where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
                         .where(published: true)
                         .includes(:category)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(24)
    else
      # Quick search for autocomplete dropdown
      @categories = Category.where("name ILIKE ?", "%#{@query}%")
                            .where(visible: true)
                            .order(:position, :name)
                            .limit(3)

      @products = Product.where("name ILIKE ?", "%#{@query}%")
                         .where(published: true)
                         .includes(:category)
                         .order(created_at: :desc)
                         .limit(5)
    end

    @results = {
      categories: @categories.map { |c| category_to_json(c) },
      products: @products.map { |p| product_to_json(p) }
    }

    handle_response
  end

  private

  def handle_response
    respond_to do |format|
      format.html
      format.json { render json: { query: @query, results: @results } }
    end
  end

  def category_to_json(category)
    {
      id: category.id,
      name: category.name,
      slug: category.slug,
      product_count: category.products.count
    }
  end

  def product_to_json(product)
    {
      id: product.id,
      name: product.name,
      price: product.discounted_price || product.price,
      original_price: product.price,
      currency: product.currency || "$",
      category_name: product.category&.name,
      category_id: product.category_id,
      image_url: product.product_images.first&.image&.url,
      published: product.published
    }
  end
end
