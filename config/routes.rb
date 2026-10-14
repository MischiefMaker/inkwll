Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]

  resources :characters, except: :destroy
  resource :active_character, only: :update
  resources :rooms, only: %i[ index show ]
  resources :exits, only: [] do
    resource :movement, only: :create
  end
  resources :ooc_messages, only: %i[ index create ]

  namespace :admin do
    resources :rooms, only: %i[ new create edit update ] do
      resources :exits, only: %i[ create destroy ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#show"
end
