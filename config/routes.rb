Rails.application.routes.draw do
  root 'home#index'

  resources :games do
    member do
      post 'submit_mulligan'
      post 'play_card'
      post 'end_turn'
      post 'minion_combat'
      post 'player_combat'
    end
  end
  resources :battlecries, only: [] do
    member do
      get 'targets'
    end
  end
  resources :account_decks do
    member do
      post 'insert_card'
      post 'remove_card'
    end
  end
  resources :card_references, only: %i[index show]
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
