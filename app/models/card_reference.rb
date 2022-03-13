class CardReference < ApplicationRecord
  belongs_to :card_constant
  # Data used for a card creation template, not data that I would want to keep loading tho
end
