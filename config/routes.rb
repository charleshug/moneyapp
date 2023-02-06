Rails.application.routes.draw do
  get 'settings', to: 'settings#index'
  root "accounts#index"
  resources :reports
  resources :ledgers, only: [:index, :edit, :update]
  get 'budgets/index'
  get 'categories/index'
  get 'categories/new'
  get 'categories/show'
  get 'categories/edit'
  
  #get "/trxes/clear_filters", to: "trxes#clear_filters", as: :clear_filters
  get "/trxes/clear_filters", to: "trxes#clear_filters", as: :clear
  resources :trxes do 
    post :new, on: :new #on: is non-RESTful, member route, rails guide 2.10 
    collection do
      get 'sort'
      post :import
    end
  end 
  

  post "/trxes/build", to: "trxes#build", as: :new_build_trx
  patch "/trxes(/:id)/build", to: "trxes#build", as: :build_trx
  #post "/trxes(/:id)/build/:association", to: "trxes#build", as: :build_trx
  
  #post 'trxes(/:id)/build/:association', to: 'trxes#build', as: :build_trx

  resources :accounts
  resources :categories
  resources :budgets, only: [:index]
  resources :vendors
end
