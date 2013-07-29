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

  resources :users, only: [:new, :create]
  resources :projects, only: [:new, :create, :index]

  match ':action' => 'site'
  root to: 'site#index'

end
