class AccountDeckCardReference < ApplicationRecord
  belongs_to :account_deck, counter_cache: :card_count
  belongs_to :card_reference
end
