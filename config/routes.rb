Rails.application.routes.draw do
  # API endpoints
  namespace :api do
    resources :product_questions, only: [ :index, :create ]
  end

  # Devise authentication routes
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Custom Devise routes
  devise_scope :user do
    get "users/sessions", to: "devise/sessions#index", as: "user_sessions"
  end

  # Main resources
  resources :sellers do
    collection do
      get "thanks", to: "sellers#thanks"
    end
  end
  resources :categories
  resources :products do
    resources :reviews, only: [ :new, :create ]
  end
  resources :orders, only: [ :index, :show ]

  # Search functionality
  get "search", to: "search#index", as: :search

  # Seller routes
  get "become-a-seller", to: "sellers#new", as: "become_seller"
  get "sellers/dashboard", to: "sellers#dashboard", as: "sellers_dashboard"
  get "sellers/products", to: "sellers#products", as: "sellers_products"
  get "sellers/products/new", to: "sellers#new_product", as: "new_sellers_product"
  post "sellers/products", to: "sellers#create_product", as: "create_sellers_product"
  get "sellers/products/:id/edit", to: "sellers#edit_product", as: "edit_sellers_product"
  patch "sellers/products/:id", to: "sellers#update_product", as: "update_sellers_product"
  delete "sellers/products/:id", to: "sellers#delete_product", as: "delete_sellers_product"

  # User account routes
  devise_scope :user do
    get "account", to: "users/registrations#edit", as: :account
  end
  get "account/orders", to: "orders#index", as: :account_orders
  get "account/downloads", to: "downloads#index", as: :account_downloads
  get "account/wishlist", to: "wishlist_items#index", as: :account_wishlist
  post "account/wishlist/add", to: "wishlist_items#create", as: :add_to_wishlist

  # Cart routes
  get "cart", to: "carts#show", as: :cart
  post "cart/add", to: "carts#add_item", as: :add_to_cart
  delete "cart/remove", to: "carts#remove_item", as: :remove_item_cart
  patch "cart/update", to: "carts#update_quantity", as: :update_quantity_cart
  delete "cart/clear", to: "carts#clear", as: :clear_cart

  # Checkout routes
  get "checkout", to: "checkouts#new", as: :checkout
  post "checkout", to: "checkouts#create"

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "dashboard/schedule", to: "dashboard#schedule", as: :dashboard_schedule

  # Admin routes
  namespace :admin do
    resources :product_questions, except: [ :new, :create ]
  end

  # Static/Content pages
  get "about", to: "pages#about", as: :about
  get "seller-info", to: "pages#become_a_seller", as: :seller_info
  get "contact", to: "pages#contact", as: :contact
  post "/contact", to: "pages#contact_submit", as: "contact_submit"

  # Help center routes
  get "help", to: "pages#help", as: :help
  get "help/:category", to: "pages#help_category", as: :help_category
  get "help/:category/:article", to: "pages#help_article", as: :help_article

  # Health check (for monitoring)
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root to: "home#index"
end
