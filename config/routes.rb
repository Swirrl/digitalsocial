Digitalsocial::Application.routes.draw do

  devise_for :organisations

  devise_for :admins

  namespace :admin do
    resources :pages
    resources :blog_posts
    resources :events
    resources :admins, only: [:index, :edit, :update]
    root to: 'pages#index'
  end

  resources :organisations, only: [:new, :create]

  match ':action' => 'site'
  root to: 'site#index'

end
