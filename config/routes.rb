Digitalsocial::Application.routes.draw do

  devise_for :admins

  match ':action' => 'site'
  root to: 'site#index'

end
