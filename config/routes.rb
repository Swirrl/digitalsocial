Digitalsocial::Application.routes.draw do
  root to: 'site#index'
  get '/blog' => 'site#blog'
  get '/events' => 'site#events'
  get '/terms' => 'site#terms'
  get '/about' => 'site#about'

  devise_for :users

  devise_for :admins

  namespace :admin do
    resources :pages
    resources :blog_posts
    resources :events
    resources :admins, only: [:index, :edit, :update]
    root to: 'pages#index'
  end

  resource :user, :only => [:edit, :update]

  resources :users, only: [:new, :create] do
    member do
      get 'edit_invited'
      post 'update_invited'
    end
  end

  resources :projects, only: [:new, :create, :index, :edit, :update, :show] do
    member do
      get 'invite'
      post 'create_new_org_invite'

      #these are one-click. Prob should be a PUT/POST but we want to do it from JS.
      get 'create_existing_org_invite'
      get 'request_to_join'
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

  resources :project_invites do
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

  namespace :organisations do
    namespace :build do
      get 'new_user'
      post 'create_user'
      get 'new_organisation'
      post 'create_organisation'
      get 'edit_organisation'
      put 'update_organisation'
      get 'new_project'
      post 'create_project'
      get 'edit_project'
      put 'update_project'
      get 'invite_organisations'
      post 'create_new_organisation_invite'
    end
  end

  resources :organisations, only: [:edit, :update, :index, :show] do
    member do
      get 'invite_users'
      put 'create_user_invites'
      get 'request_to_join'
      get 'edit_location'
      post 'update_location'
      get 'map_show'
    end
    collection do
      get 'map_index'
    end
  end

  get 'reach_question_text' => "projects#reach_question_text"
  get 'dashboard' => 'dashboard#pending'
  get 'dashboard/projects' => 'dashboard#projects'
  get 'dashboard/users' => 'dashboard#users'

  # fall through - 404s
  match '*a', :to => 'errors#routing'

end
