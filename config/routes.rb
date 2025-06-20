Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'welcome#index'

  resources :posts
  resources :families do
    resources :family_invitations, only: [:new, :create, :index], path: 'invitations'
    resources :milestones, only: [:index, :show]
  end
  resources :milestones
  resources :relationships, except: [:edit, :update]
  resources :timeline, only: [:index]
  get '/timeline/truncated', to: 'timeline#show_truncated'
  
  resources :family_invitations, only: [:show, :destroy] do
    member do
      get :accept_form
      post :accept
      post :decline
    end
  end
  
  resources :users do
    resources :posts, only: [:index]
    resources :milestones, only: [:index, :show]
  end
  resources :posts do
    resources :milestones, only: [:index, :show]
  end

  get '/login', to: 'users#login_form'
  post '/login', to: 'users#login'
  post '/logout', to: 'users#logout'
  
  # Public invitation acceptance (no login required)
  get '/invite/:token', to: 'family_invitations#show', as: 'public_invitation'
end
