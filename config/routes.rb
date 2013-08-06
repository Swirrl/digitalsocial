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

  resources :users, only: [:new, :create, :edit, :update] do
    member do
      get 'edit_invited'
      post 'update_invited'
    end
  end

  resources :projects, only: [:new, :create, :index, :edit, :update] do
    member do
      get 'invite'
      post 'create_invite'
    end
    collection do
      post 'create_request'
    end
  end

  resources :requests do
    member do
      put 'accept'
      put 'reject'
    end
  end

  match ':action' => 'site'
  root to: 'site#index'

end
