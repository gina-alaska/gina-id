Rails.application.routes.draw do
  resources :identities
  get '/signout', to: 'sessions#destroy'
  get '/signin', to: 'sessions#new'
  get '/auth/:provider/disable', to: 'users#disable_provider'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/settings', to: 'users#show'

  resources :sessions do
    get :verify, on: :collection
  end
  resources :memberships

  #open id server routes
  resources :servers, path: :openid, except: [:new, :edit, :update, :destroy] do
    get :xrds, on: :collection
    get :user_xrds, on: :member
    post :decision, on: :collection
  end
  resources :users do
    get :confirm_migration, on: :member

    collection do
      get :forgot_password
      post :send_reset_instructions
      get :send_confirmation_email
      get :reset_password
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get ':id' => 'servers#show', :constraints => { :id => /.+/ }, :as => :user_identity
  get ':id/xrds' => 'servers#user_xrds'

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
