class AccountDeck < ApplicationRecord
  has_and_belongs_to_many :party_card_parents
  belongs_to :user
  belongs_to :archetype
  belongs_to :race
end
