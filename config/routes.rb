Rails.application.routes.draw do  
  get "notion_database/index"
  resource :session
  resources :passwords, param: :token
  root "home#index"

  resources :notion_database, only: [:index] do
    get  :insert, on: :collection
    post :create_in_notion, on: :collection
  end  
  resources :user, only: [:new, :create, :destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/auth/notion/callback', to:'notion#index'
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
