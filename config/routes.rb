Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'welcome#index'

  resources :posts
  resources :families
  resources :milestones
  resources :timeline, only: [:index]
  get '/timeline/truncated', to: 'timeline#show_truncated'
  resources :users do
    resources :posts, only: [:index]
    resources :milestones, only: [:index, :show]
  end
  resources :families do
    resources :milestones, only: [:index, :show]
  end
  resources :posts do
    resources :milestones, only: [:index, :show]
  end

  get '/login', to: 'users#login_form'
  post '/login', to: 'users#login'
  post '/logout', to: 'users#logout'
end
