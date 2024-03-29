Rails.application.routes.draw do
  get 'settings', to: 'settings#index'
  root "accounts#index"
  resources :reports
  resources :ledgers, only: [:index, :edit, :update]
  get 'budgets/index'
  
  #get "/trxes/clear_filters", to: "trxes#clear_filters", as: :clear_filters
  get "/trxes/clear_filters", to: "trxes#clear_filters", as: :clear
  resources :trxes do 
    post :new, on: :new #on: is non-RESTful, member route, rails guide 2.10 
    collection do
      get 'sort'
      post :import
      put :bulk_update, to: 'trxes#bulk_update', as: 'bulk_update'
    end
  end 
  

  post "/trxes/build", to: "trxes#build", as: :new_build_trx
  patch "/trxes(/:id)/build", to: "trxes#build", as: :build_trx
  #post "/trxes(/:id)/build/:association", to: "trxes#build", as: :build_trx
  
  #post 'trxes(/:id)/build/:association', to: 'trxes#build', as: :build_trx

  patch "/accounts/:id/update_position", to: "accounts#update_position", as: "update_position"
  resources :accounts
  resources :categories do
    get 'categories_data', on: :collection
  end
  resources :budgets, only: [:index]
  resources :vendors
end
