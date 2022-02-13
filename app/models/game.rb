#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: games
#
# id                      :bigint       null: false, primary key
# turn                    :boolean      default: true
# ongoing                 :boolean      default: true
# winner_id               :integer      null: true, foreign key of user
# status                  :string       default: "mulligan"
#

class Game < ApplicationRecord
  #=======================================|GAME CALLBACKS|==========================================
  after_create_commit do
    build_player_one(turn_order: true)
    build_player_two(turn_order: false)
  end

  #=======================================|SCOPES|==========================================

  scope :with_players_and_decks, lambda {
                                   includes(player_one: { gamestate_deck: :party_card_gamestates },
                                            player_two: { gamestate_deck: :party_card_gamestates })
                                 }

  #=======================================|GAME ASSOCIATIONS|=======================================

  has_many :players, class_name: :Player,
                     foreign_key: :game_id,
                     inverse_of: :game,
                     dependent: :destroy

  has_one :player_one, -> { where('turn_order = true') },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  has_one :player_two, -> { where('turn_order = false') },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  has_one :current_player, ->(game) { where('turn_order = ?', game.turn) },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  belongs_to :winner, optional: true,
                      class_name: :User,
                      foreign_key: :winner_id

  #=======================================|GAME METHODS|=====================================
  def self.form_game(queued_deck_one, queued_deck_two)
    new_game = Game.create!
    new_game.populate_players(queued_deck_one, queued_deck_two)
    new_game.populate_decks(queued_deck_one, queued_deck_two)
    new_game
  end

  def populate_players(queued_deck_one, queued_deck_two)
    player_one.prepare_player(queued_deck_one)
    player_two.prepare_player(queued_deck_two)
  end

  def populate_decks(queued_deck_one, queued_deck_two)
    player_one.gamestate_deck.prepare_deck(queued_deck_one)
    player_two.gamestate_deck.prepare_deck(queued_deck_two)
  end
end
