class AccountDeck < ApplicationRecord
  belongs_to :user
  belongs_to :archetype
  belongs_to :race
end
