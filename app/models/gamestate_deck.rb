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
  has_many :cards, dependent: :destroy

  def prepare_deck(queued_deck)
    queued_deck.card_references.includes(:card_constant).each do |card|
      cards.create!(
        cost: card.cost,
        health: card.health,
        attack: card.attack,
        health_cap: card.health,
        location: 'deck',
        status: 'unplayed',
        type: card.card_type,
        card_constant: card.card_constant
      )
    end
  end
end
