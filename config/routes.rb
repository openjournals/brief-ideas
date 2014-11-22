Rails.application.routes.draw do
  resources :ideas do
    collection do
      get :preview
      get :tags
    end
  end

  resources :votes, :only => :create
  resources :users, :only => :show

  get '/sessions/new', to: 'sessions#new', as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  # Sidekiq
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root :to => 'ideas#index'
end
