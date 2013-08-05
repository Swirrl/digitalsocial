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

  resources :users, only: [:new, :create, :edit] do
    member do
      get 'edit_invited'
      post 'update_invited'
    end
  end

  resources :projects, only: [:new, :create, :index] do
    member do
      get 'invite'
      post 'create_invite'
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
