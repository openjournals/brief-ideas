Rails.application.routes.draw do
  resources :ideas do
    member do
      post :hide
      post :collect
      post :add_comment
      post :accept_invite
      post :submit
    end

    collection do
      get :preview
      get :similar
      get :tags
    end
  end

  resources :votes, :only => :create

  resources :users do
    member do
      get :show
      get :collections
    end
  end

  resources :collections do
    member do
      post :add_idea
    end
  end

  resources :admin do
    member do
      post :mute
      post :reject
      post :publish
      post :tweet
      get :remove_comment
    end
  end

  get '/user_lookup', to: "users#lookup", as: 'user_lookup'
  post '/users/update_email', to: 'users#update_email'
  get '/idea_title_lookup', to: "ideas#lookup_title", as: 'idea_title_lookup'

  get '/admin/audits/:id', to: "admin#audits", as: 'admin_audits'
  get '/trending', :to => 'ideas#trending', :as => 'trending'
  get '/boom', :to => 'ideas#boom'
  get '/all', :to => 'ideas#all', :as => 'all'
  get '/about', :to => 'ideas#about', :as => 'about'
  get '/search', :to => 'search#search', :as => 'search'
  get '/sessions/new', :to => 'sessions#new', :as => 'new_session'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  # Sidekiq
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # Starburst
  mount Starburst::Engine => "/starburst"

  root :to => 'ideas#index'
end
