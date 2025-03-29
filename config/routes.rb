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
  get "account/downloads", to: "downloads#index", as: :downloads
  get "account/downloads/:token", to: "downloads#show", as: :download
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

  # Payment routes
  post "payments", to: "payments#create", as: :create_payment

  # Stripe routes
  get "payments/stripe/success", to: "payments#stripe_success", as: :stripe_success
  get "payments/stripe/cancel", to: "payments#stripe_cancel", as: :stripe_cancel
  post "stripe/webhooks", to: "stripe_webhooks#create"

  # Mobile Money routes
  post "payments/momo", to: "payments#momo_initiate", as: :momo_payment
  get "payments/momo/verify/:transaction_ref", to: "payments#momo_verify", as: :momo_verify
  post "momo/webhooks/:provider", to: "momo_webhooks#create", as: :momo_webhook

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "dashboard/schedule", to: "dashboard#schedule", as: :dashboard_schedule

  # Admin routes
  namespace :admin do
    resources :product_questions, except: [ :new, :create ]
    resources :downloads do
      member do
        post :regenerate
      end
    end
    resources :payments, only: [ :index, :show, :update ]

    # Admin dashboard
    get "/", to: "dashboard#index", as: :dashboard
    get "/analytics", to: "dashboard#analytics", as: :analytics
  end

  # Super Admin routes
  namespace :super_admin do
    # Login for super admin
    get "/login", to: "sessions#new", as: :login_form
    post "/login", to: "sessions#create", as: :login

    # Dashboard
    get "/", to: "dashboard#index", as: :dashboard

    # User management
    resources :users do
      member do
        post :impersonate
        post :toggle_admin
      end
      collection do
        post :stop_impersonation
      end
    end

    # System monitoring
    get "/system", to: "system#index", as: :system
    get "/system/logs", to: "system#logs", as: :logs
    post "/system/clear_cache", to: "system#clear_cache", as: :clear_cache
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
