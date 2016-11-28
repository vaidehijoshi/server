Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :addons, only: [:index, :update]
    get 'hidden' => 'addons#hidden'
    get 'addons/:name' => 'addons#show'
    resources :categories, only: [:index, :create, :update]
    get 'categories/:name' => 'categories#show'
    resources :keywords, only: [:show, :index]
    resources :versions, only: [:show, :index]
    resources :reviews, only: [:show, :create, :index]
    resources :maintainers, only: [:index]
    post 'corrections' => 'corrections#submit'
    get 'search/addons' => 'search#addons'
    get 'search/source' => 'search#source'

    resources :build_servers, only: [:index, :create, :update, :destroy]
    resources :test_results, only: [:index, :create, :show]

    post 'build_queue/get_build' => 'build_queue#get_build'
    post 'test_results/:id/retry' => 'test_results#retry'

    get 'search' => 'search#search'

    scope :authentication do
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
    end
  end

  namespace :api do
    namespace :v2 do
      get 'autocomplete_data' => 'autocomplete#data'
      jsonapi_resources :addons
      jsonapi_resources :categories
      jsonapi_resources :maintainers
      jsonapi_resources :test_results
    end
  end
end
