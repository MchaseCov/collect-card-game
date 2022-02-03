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
end
