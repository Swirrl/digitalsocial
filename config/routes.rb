Digitalsocial::Application.routes.draw do

  match ':action' => 'site'
  root to: 'site#index'

end
