Rails.application.routes.draw do
  namespace :admin do
    resources :customers
    resources :line_items, except: [:index]
    resources :log_entries
    resources :orders
    resources :pages
    resources :products
    resources :product_meta_tags
    resources :payments, only: [:index, :show]
    resources :series

    namespace :blog do
      resources :posts
      resources :tags
    end

    root to: "customers#index"
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root to: redirect("/admin")
end
