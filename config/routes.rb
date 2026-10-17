Rails.application.routes.draw do
  # www.inkwll.com sends visitors on to inkwll.com (the game's APP_HOST), so
  # there's one address and logins don't split between the two.
  www_visit = ->(request) { ENV["APP_HOST"].present? && request.host == "www.#{ENV["APP_HOST"]}" }
  constraints(www_visit) do
    match "(*path)", via: :all, format: false,
      to: redirect(status: 301) { |_params, request| request.url.sub("://www.", "://") }
  end

  # Inkwll uploads images through its own forms, so Active Storage's
  # "upload straight to storage" addresses are switched off: they don't check
  # who's logged in or what the file is, and could be used to fill the disk.
  not_found = ->(_env) { [ 404, { "content-type" => "text/plain" }, [ "Not found" ] ] }
  post "/rails/active_storage/direct_uploads", to: not_found
  put "/rails/active_storage/disk/:encoded_token", to: not_found

  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :notification_settings, only: %i[ edit update ]
  # One-click "stop these emails" links. GET shows a button; POST (also what
  # mail apps send) turns emails off.
  get "unsubscribe/:token", to: "unsubscribes#show", as: :unsubscribe
  post "unsubscribe/:token", to: "unsubscribes#create"

  resources :characters, except: :destroy do
    scope module: :characters do
      resources :gallery_images, only: %i[ create destroy ]
      resources :relationships, only: %i[ create destroy ]
      resource :submission, only: :create
      resource :sheet, only: :update
      resource :sheet_lock, only: %i[ create destroy ]
      resources :xp_spends, only: :create
      resources :xp_entries, only: :create
      resources :bnbs, only: %i[ create update destroy ]
      resources :bnb_requests, only: :create
      resources :culminations, only: %i[ create update ]
      resource :roster_request, only: %i[ create destroy ]
      resource :looking_for_rp, only: %i[ create destroy ]
      resource :looking_for_rp_nudge, only: :create
      resources :spells, only: :create
      resources :spell_proposals, only: :create
      resources :roster_applications, only: %i[ new create ]
      resources :payments, only: :create
      resources :payment_schedules, only: %i[ create destroy ]
      resources :item_gifts, only: :create
      resources :trades, only: :create
      resources :crafts, only: %i[ new create ]
      resources :feature_proposals, only: :create
    end
  end
  # Items (Crafting): an item's page, putting it on the Market and buying it.
  resources :items, only: %i[ show update ] do
    scope module: :items do
      resource :listing, only: %i[ create destroy ]
      resource :purchase, only: :create
    end
  end
  resources :trades, only: %i[ index show update destroy ] do
    member { post :agree }
  end
  get "market", to: "market#index"
  resource :active_character, only: :update
  resources :areas, only: :show
  resources :saved_places, only: :index, path: "my_places"
  resources :players, only: %i[ index show ], param: :name
  resource :player_profile, only: %i[ edit update ]
  resources :rooms, only: %i[ index show ] do
    resources :shop_purchases, only: :create, module: :rooms
    resource :travel, only: :create
    resource :saved_place, only: %i[ create destroy ]
  end
  resources :exits, only: [] do
    resource :movement, only: :create
  end
  resources :ooc_messages, only: %i[ index create edit update destroy ]
  resources :warnings, only: :update

  # Scenes are shown to players as Chapters, and poses as Passages.
  resources :scenes, only: %i[ index show create edit update ] do
    scope module: :scenes do
      resource :participation, only: %i[ create update destroy ]
      resource :writing_as, only: :update, controller: "writing_as"
      resource :finish, only: %i[ create destroy ]
      resource :pause, only: %i[ create destroy ]
      resource :storyteller_wanted, only: %i[ create destroy ]
      resource :ruling_request, only: %i[ create destroy ]
      resource :summary, only: :update
      resources :asides, only: :create
      resource :public_consent, only: %i[ create destroy ]
      resources :reports, only: %i[ new create ]
      resources :invitations, only: :create
      resources :rolls, only: :create
      resources :casts, only: :create
      resources :npc_rolls, only: :create
      resources :casts, only: :create
      resources :inkling_links, only: :create
      resources :pending_rolls, only: %i[ create update destroy ]
      resources :award_suggestions, only: :create
      resource :reading, only: :update
      resource :turn, only: [] do
        post :pass
        post :skip
        post :here
      end
    end
    resources :poses, only: %i[ create edit update destroy ]
  end
  # Messages: out-of-character conversations between players.
  resources :conversations, path: "messages", only: %i[ index new create show ] do
    scope module: :conversations do
      resources :messages, only: :create
      resource :membership, only: :destroy
    end
  end
  resource :chapter_tabs, only: :show
  delete "chapter_tabs/:participant_id", to: "chapter_tabs#close", as: :close_chapter_tab
  get "where", to: "where#show"
  get "getting-started", to: "guides#show", as: :getting_started
  get "how-it-works", to: redirect("/getting-started")
  # The Bookshelf (finished Chapters). The route keeps its plain name in code;
  # the old /archives address redirects, keeping its filters.
  get "bookshelf", to: "archives#index", as: :archives
  get "archives", to: redirect { |_params, request| "/bookshelf#{"?#{request.query_string}" if request.query_string.present?}" }
  get "directory", to: "directory#index"
  get "my_chapters", to: "chapter_trackers#show"
  resources :alerts, only: :index
  get "birthdays", to: "birthdays#index"
  get "graveyard", to: "graveyard#index"
  get "looking-for-rp", to: "looking_for_rp#index", as: :looking_for_rp
  get "storyteller-wanted", to: "storyteller_wanted#index", as: :storyteller_wanted
  resource :account_waiting, only: :show, path: "waiting"
  resources :factions, only: %i[ index show ] do
    resources :memberships, only: %i[ create update destroy ], module: :factions
    resources :requests, only: %i[ create update destroy ], module: :factions
    scope module: :factions do
      resource :bank, only: :update
      resources :bank_payments, only: :create
      resources :bank_schedules, only: %i[ create destroy ]
    end
  end
  resources :domains, only: %i[ index update ]
  resources :inklings, only: %i[ index new create show update ] do
    scope module: :inklings do
      resources :entries, only: :create
      resources :rolls, only: :create
      resources :casts, only: :create
      resource :submission, only: :create
      resource :review, only: :create
      resource :closing, only: %i[ create destroy ]
      resources :shares, only: %i[ create destroy ]
      resources :rewards, only: :create
    end
  end
  get "skin.css", to: "skins#show", as: :skin_stylesheet
  get "roster", to: "directory#index", defaults: { roster: "1" }, as: :roster
  resources :wiki_pages, path: "wiki", param: :slug do
    collection { post :preview }
    scope module: :wiki_pages do
      resources :revisions, only: %i[ index show update ]
      resource :lock, only: %i[ create destroy ]
    end
  end

  # Forum boards (news, advertising, wanted ads...) and their threads.
  resources :forum_boards, path: "boards", only: %i[ index show ] do
    resources :forum_topics, path: "threads", only: %i[ new create ]
  end
  resources :forum_topics, path: "threads", only: %i[ show edit update destroy ] do
    resources :forum_posts, path: "posts", only: %i[ create edit update destroy ]
  end

  # The admin panel. Each section checks the visitor's staff level.
  namespace :admin do
    root "dashboard#show"
    get "getting-started", to: "guides#show", as: :getting_started
    resources :areas, only: %i[ index new create edit update destroy ]
    resources :name_changes, only: :index
    resource :bulk_build, only: %i[ new create ], path: "build_several"
    resources :rooms, only: %i[ new create edit update destroy ] do
      resources :exits, only: %i[ create edit update destroy ]
      resource :numbered_rooms, only: :create
    end
    resources :accounts, only: %i[ index edit update destroy ] do
      member do
        post :unmute
        post :archive
        post :reset_link
      end
    end
    resource :character_batch, only: :create
    resource :account_batch, only: :create
    resources :account_approvals, only: %i[ update destroy ]
    resources :characters, only: %i[ index update ] do
      member do
        post :retire
        post :unretire
        post :decease
      end
    end
    resource :game_settings, only: %i[ edit update ]
    resource :features, only: %i[ edit update ]
    resource :game_lock, only: %i[ create destroy ]
    resource :skin, only: %i[ edit update ]
    resources :skin_fonts, only: :destroy
    resource :wells, only: %i[ show create ]
    resources :well_updates, only: :create
    resource :world_import, only: %i[ show create ] do
      get :preview
      post :apply
    end
    resources :profile_fields, except: %i[ show new ]
    resources :character_groups, except: %i[ show new ]
    resources :factions, except: %i[ show new ]
    resources :scene_labels, except: %i[ show new ]
    resources :scene_ideas, only: %i[ index create destroy ]
    resources :forum_boards, except: %i[ show new ]
    resource :soul, only: :show, controller: "soul"
    resources :soul_aspects, only: %i[ create edit update destroy ]
    resources :soul_skills, only: %i[ create edit update destroy ]
    resources :soul_rating_guides, only: %i[ create edit update destroy ]
    resources :soul_bnbs, only: %i[ index create edit update destroy ]
    resources :soul_reviews, only: %i[ index update ]
    resources :soul_award_suggestions, only: :update
    resources :applications, only: %i[ index show update ]
    resource :roster, only: :show, controller: "roster"
    resources :roster_applications, only: :update
    resources :inklings, only: :index
    resource :grimoire, only: :show, controller: "grimoire"
    resources :grimoire_branches, only: %i[ create edit update destroy ]
    resources :grimoire_spells, only: %i[ create edit update ]
    resources :grimoire_proposals, only: :update
    resources :roster_characters, only: %i[ create update ]
    resource :economy, only: %i[ show update ], controller: "economy"
    resources :economy_adjustments, only: :create
    resources :economy_schedules, only: %i[ create destroy ]
    resources :economy_allowance_changes, only: %i[ create destroy ]
    resources :domains, except: %i[ show new ]
    resources :catalogue_items, except: %i[ show new ]
    resources :items, only: %i[ create edit update destroy ]
    resource :crafting, only: %i[ show update ], controller: "crafting"
    resources :crafting_item_types, except: %i[ show new index ]
    resources :crafting_features, except: %i[ show new index ]
    resources :reports, only: %i[ index show update ]
    resources :poses, only: [] do
      resource :hiding, only: :create
    end
    resources :scenes, only: [] do
      resource :lock, only: %i[ create destroy ]
    end
    resources :warnings, only: %i[ new create ]
    resources :rulings, only: %i[ index update ]
    resources :bans, only: %i[ index new create update ]
    # Removes every OOC Chat message a guest sent from one address.
    delete "guest_messages", to: "guest_messages#destroy", as: :guest_messages
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "well_status", to: "well_status#show"

  root "home#show"
end
