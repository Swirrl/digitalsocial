Digitalsocial::Application.routes.draw do

  devise_for :admins

  namespace :admin do
    resources :pages
    resources :blog_posts
    resources :events
  end

  match ':action' => 'site'
  root to: 'site#index'

end
