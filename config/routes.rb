Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "welcome#index"

  resources :posts
  resources :users do
    resources :posts, only: [:index]
  end

  get "/login", to: "users#login_form"
  post "/login", to: "users#login"
  post "/logout", to: "users#logout"
end
