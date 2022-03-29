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

  def generate_cards(amount, card_stats, buffs = nil)
    left_direction = right_direction = card_stats[:position]
    amount.times do |i|
      generated_position = ((i.even? ? right_direction += 1 : left_direction -= 1))
      generated_card = cards.new(card_stats)
      generated_card.buffs << buffs if buffs
      generated_card.attributes = card_stats if buffs # "Undo" the buff callbacks
      generated_card.position = generated_position
      generated_card.save
    end
  end
end
