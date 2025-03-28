class HomeController < ApplicationController
  def index
    # Fetch actual data for production
    @stats = {
      total_products: Product.count,
      total_sellers: Seller.count,
      total_categories: Category.count,
      countries_served: 2 # Ghana and Nigeria
    }

    # You might also want to add these for other sections
    @featured_products = Product.where(featured: true).limit(8)
    @top_categories = Category.where(visible: true).order(position: :asc).limit(4)
    @top_sellers = Seller.where(verified: true).order(acceptance_rate: :desc).limit(3)
  end

  def categories
    @featured_categories = [
      { name: "Fashion", description: "Trending styles from local designers", color: "indigo", image_url: "https://via.placeholder.com/400x400/6366f1/ffffff?text=Fashion" },
      { name: "Home & Living", description: "Handcrafted decor & furniture", color: "green", image_url: "https://via.placeholder.com/400x400/10b981/ffffff?text=Home" },
      { name: "Food & Groceries", description: "Fresh local produce & spices", color: "amber", image_url: "https://via.placeholder.com/400x400/f59e0b/ffffff?text=Food" },
      { name: "Art & Crafts", description: "Authentic African artworks", color: "purple", image_url: "https://via.placeholder.com/400x400/8b5cf6/ffffff?text=Art" }
    ]
  end
end
