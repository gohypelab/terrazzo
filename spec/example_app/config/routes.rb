Rails.application.routes.draw do
  root to: redirect("/admin")

  namespace :admin do
        resources :countries
        resources :customers
        resources :hosts
        resources :line_items
        resources :log_entries
        resources :orders
        resources :pages
        resources :payments
        resources :product_meta_tags
        resources :products
        resources :series

        namespace :blog do
          resources :posts
          resources :tags
        end

      root to: "countries#index"
    end
  get "up" => "rails/health#show", as: :rails_health_check
end
