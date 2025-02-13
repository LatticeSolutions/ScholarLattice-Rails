Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "landing#index"

  resources :collections do
    resources :pages, shallow: true, except: :index
    resources :submissions, shallow: true
    resources :events, shallow: true
  end
  get "/collections/:id/new", to: "collections#new_subcollection", as: "new_subcollection"
  get "/collections/:id/like", to: "collections#like", as: "like_collection"
  get "/collections/:id/dislike", to: "collections#dislike", as: "dislike_collection"

  resources :profiles, except: :index

  get "/dashboard/", to: "dashboard#index"
  get "/privacy/", to: "static_pages#privacy"
  get "/tos/", to: "static_pages#tos"

  # Passwordless routes
  passwordless_for :users, controller: "sessions"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
