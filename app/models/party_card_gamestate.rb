class PartyCardGamestate < ApplicationRecord
  belongs_to :archetype
  belongs_to :party_card_parent
  belongs_to :gamestate_deck
end
