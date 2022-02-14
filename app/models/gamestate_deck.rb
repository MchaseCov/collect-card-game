#=======================================|GAMESTATE DECK TABLE SCHEMA|=======================================
#
# table name: gamestate_decks
#
# id                      :bigint       null: false, primary key
# card_count              :integer
# player_id               :bigint       null: false, foreign key of PLayer table
# game_id                 :bigint       null: false, foreign key of Game table
#
class GamestateDeck < ApplicationRecord
  validates :card_count, numericality: { in: 0..60 }, presence: true

  belongs_to :player
  belongs_to :game
  has_many :party_card_gamestates, -> { includes(:party_card_parent, :archetype) }, dependent: :destroy

  def prepare_deck(queued_deck)
    queued_deck.party_card_parents.includes(:archetype).each do |card|
      party_card_gamestates.create!(
        health_cap: card.health_default,
        health_current: card.health_default,
        cost_current: card.cost_default,
        attack_cap: card.attack_default,
        attack_current: card.attack_default,
        location: 'deck',
        status: 'unplayed',
        archetype: card.archetype,
        party_card_parent: card
      )
    end
  end

  def cards
    party_card_gamestates # .or(action_card_gamestates);
  end
end
