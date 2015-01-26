Rails.application.routes.draw do
  resources :ideas do
    collection do
      get :preview
      get :similar
      get :tags
    end
  end

  resources :votes, :only => :create
  resources :users, :only => :show

  get '/user_lookup', to: "users#lookup", as: 'user_lookup'
  get '/idea_title_lookup' , to: "ideas#lookup_title", as: 'idea_title_lookup'

  get '/trending', :to => 'ideas#trending', :as => 'trending'
  get '/about', :to => 'ideas#about', :as => 'about'
  get '/search', :to => 'search#search', :as => 'search'
  get '/sessions/new', :to => 'sessions#new', :as => 'new_session'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  # Sidekiq
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root :to => 'ideas#index'
end
