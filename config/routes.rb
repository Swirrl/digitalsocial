Digitalsocial::Application.routes.draw do

  devise_for :users

  devise_for :admins

  namespace :admin do
    resources :pages
    resources :blog_posts
    resources :events
    resources :admins, only: [:index, :edit, :update]
    root to: 'pages#index'
  end

  resource :user, :only => [:show, :edit, :update]

  resources :users, only: [:new, :create] do
    member do
      get 'edit_invited'
      post 'update_invited'
    end
  end

  resources :projects, only: [:new, :create, :index, :edit, :update] do
    member do
      get 'invite'
      post 'create_invite'
      get 'request_to_join' #one-click. Prob should be a PUT/POST but we want to do it from JS.
    end
    collection do
      get 'tags'
    end
  end

  resources :project_requests do
    member do
      put 'accept'
      put 'reject'
    end
  end

  resources :user_requests, only: [:index, :create] do
    member do
      put 'accept'
      put 'reject'
    end
    collection do
      post 'create_invite'
    end
  end

  resources :organisations, only: [:edit, :update, :index] do
    member do
      get 'user_invite'
      post 'create_user_invite'
      get 'request_to_join'
      get 'edit_location'
      post 'update_location'
    end
  end

  namespace :organisations do
    namespace :build do
      get 'new_user'
      post 'create_user'
      get 'new_organisation'
      post 'create_organisation'
      get 'edit_organisation'
      put 'update_organisation'
      get 'invite_users'
      put 'create_user_invites'
      get 'new_project'
      post 'create_project'
      get 'edit_project'
      put 'update_project'
    end
  end

  match ':action' => 'site'
  root to: 'site#index'

end
