RailsApp::Application.routes.draw do
  resources :users

  resource :user_session, :only => [:new, :create, :destroy]
  match 'login' => 'user_sessions#new', :as => :login, :via => :get
  match 'login' => 'user_sessions#create', :as => :login, :via => :post
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :get
  match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :delete
  match 'confirm' => 'user_sessions#confirm', :as => :confirm, :via => :get
  match 'validate' => 'user_sessions#validate', :as => :validate, :via => :put

  # default home page
  root :to => 'welcome#index'
end
