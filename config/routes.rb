Rails.application.routes.draw do
  get 'party_card_parents/index'
  get 'party_card_parents/show'
  root 'home#index'

  resources :games
  resources :account_decks
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
