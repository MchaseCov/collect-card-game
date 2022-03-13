class Card < ApplicationRecord
  belongs_to :gamestate_deck
  belongs_to :card_constant
end
