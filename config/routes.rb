Rails.application.routes.draw do
  root 'home#index'

  resources :games do
    member do
      post 'submit_mulligan'
    end
  end
  resources :account_decks do
    member do
      post 'insert_party_card'
      post 'remove_party_card'
    end
  end
  resources :party_card_parents, only: %i[index show]
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
