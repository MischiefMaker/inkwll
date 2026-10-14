Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :notification_settings, only: %i[ edit update ]
  # One-click "stop these emails" links. GET shows a button; POST (also what
  # mail apps send) turns emails off.
  get "unsubscribe/:token", to: "unsubscribes#show", as: :unsubscribe
  post "unsubscribe/:token", to: "unsubscribes#create"

  resources :characters, except: :destroy
  resource :active_character, only: :update
  resources :areas, only: :show
  resources :rooms, only: %i[ index show ] do
    resource :travel, only: :create
  end
  resources :exits, only: [] do
    resource :movement, only: :create
  end
  resources :ooc_messages, only: %i[ index create ]
  resources :warnings, only: :update

  # Scenes are shown to players as Chapters, and poses as Passages.
  resources :scenes, only: %i[ show create edit update ] do
    scope module: :scenes do
      resource :participation, only: %i[ create update destroy ]
      resource :finish, only: %i[ create destroy ]
      resource :public_consent, only: %i[ create destroy ]
      resources :reports, only: %i[ new create ]
      resources :invitations, only: :create
      resource :reading, only: :update
      resource :turn, only: [] do
        post :pass
        post :skip
        post :here
      end
    end
    resources :poses, only: %i[ create edit update destroy ]
  end
  resource :chapter_tabs, only: :show
  get "where", to: "where#show"
  get "archives", to: "archives#index"

  # The admin panel. Each section checks the visitor's staff level.
  namespace :admin do
    root "dashboard#show"
    resources :areas, only: %i[ index new create edit update ]
    resources :rooms, only: %i[ new create edit update ] do
      resources :exits, only: %i[ create destroy ]
    end
    resources :accounts, only: %i[ index edit update ]
    resources :characters, only: %i[ index destroy ]
    resource :game_settings, only: %i[ edit update ]
    resources :reports, only: %i[ index show update ]
    resources :poses, only: [] do
      resource :hiding, only: :create
    end
    resources :scenes, only: [] do
      resource :lock, only: %i[ create destroy ]
    end
    resources :warnings, only: %i[ new create ]
    resources :bans, only: %i[ index new create update ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#show"
end
