RailsApp::Application.routes.draw do
  resources :users

  resources :user_sessions, :only => [:new, :create, :destroy]
  match 'login' => 'user_sessions#new', :as => :login, :via => :get
  match 'login' => 'user_sessions#create', :as => :login, :via => :post
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :get
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :delete

  # default home page
  root :to => 'welcome#index'
end
