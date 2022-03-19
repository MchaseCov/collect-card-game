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
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
