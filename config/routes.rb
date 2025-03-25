Rails.application.routes.draw do
  get "pages/contact"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # Custom sessions routes
  devise_scope :user do
    get "users/sessions", to: "devise/sessions#index", as: "user_sessions"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :products, only: [ :index ]
  get "contact", to: "pages#contact", as: :contact
  get "dashboard", to: "dashboard#index", as: :dashboard
  post "/contact", to: "pages#contact_submit", as: "contact_submit"
  get "help", to: "pages#help", as: :help
  get "help/:category", to: "pages#help_category", as: :help_category
  get "help/:category/:article", to: "pages#help_article", as: :help_article

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: "home#index"
end
