Rails.application.routes.draw do
  root 'home#index'

  resources :games
  resources :account_decks do
    post 'insert_party_card'
  end
  resources :party_card_parents, only: %i[index show]
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
