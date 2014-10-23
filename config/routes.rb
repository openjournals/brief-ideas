Rails.application.routes.draw do
  resources :ideas do
    collection do
      get :preview
    end
  end

  resources :users, :only => :show

  get '/sessions/new', to: 'sessions#new', as: 'new_session'
  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  root :to => 'ideas#new'
end
