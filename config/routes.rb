Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "landing#index"

  resources :collections do
    resources :pages, shallow: true, except: :index
    resources :submissions, shallow: true
    resources :registrations, shallow: true do
      resources :registration_payments, shallow: true, as: "payments", path: "payments",
        only: [ :new, :create, :edit, :update, :destroy ]
    end
    resources :registration_options, shallow: true, path: "registrations/options",
      only: [ :new, :create, :edit, :update, :destroy ]
    resources :events, shallow: true
    get "/followers", to: "collections#likes", as: "likes"
    resources :invitations, shallow: true do
      get "/batch", to: "invitations#new_batch", on: :collection
      post "/batch", to: "invitations#create_batch", on: :collection
    end
  end
  get "/collections/:id/new", to: "collections#new_subcollection", as: "new_subcollection"
  post "/collections/:id/like", to: "collections#like", as: "like_collection"
  post "/collections/:id/dislike", to: "collections#dislike", as: "dislike_collection"
  get "/collections/:id/print", to: "collections#print", as: "print_collection"
  get "/events/:id/copy", to: "events#copy", as: "copy_event"
  get "/events/:id/subevents", to: "events#new_subevents", as: "new_subevents"
  post "/events/:id/subevents", to: "events#create_subevents", as: "create_subevents"
  post "/invitations/:id/accept", to: "invitations#accept", as: "accept_invitation"
  post "/invitations/:id/decline", to: "invitations#decline", as: "decline_invitation"

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
