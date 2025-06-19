Rails.application.routes.draw do
  resources :activities, only: [:index]
  resources :notifications, only: [:index, :show] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'welcome#index'

  resources :posts do
    resources :reactions, only: [:create, :destroy]
  end
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
