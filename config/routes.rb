Rails.application.routes.draw do
  root 'home#index'

  resources :games do
    member do
      post 'submit_mulligan'
      %i[party spell].each { |type| post "play_card/#{type}", to: "games#play_#{type}" }
      %i[party player].each { |target| post "combat/#{target}", to: "games##{target}_combat" }
      post 'end_turn'
    end
  end
  resources :multiplayer_games
  resources :singleplayer_games

  get 'battlecry/:id/targets', to: 'battlecries#targets', as: 'battlecry_targets'
  resources :account_decks do
    member do
      post 'insert_card'
      post 'remove_card'
    end
  end
  resources :card_references, only: %i[index show]
  devise_for :users
  get 'home/index'
  post '/queue/join', to: 'game_queue#join'
  post '/queue/view', to: 'game_queue#view'
  post '/queue/leave', to: 'game_queue#leave'

  resources :card_constants, only: [:index]
  resources :keywords, only: [:index]
  resources :archetypes, only: [:index]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount ActionCable.server => '/cable'
end
