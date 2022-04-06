#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: games
#
# id                      :bigint       null: false, primary key
# turn                    :boolean      default: true
# ongoing                 :boolean      default: true
# status                  :string       default: "mulligan"
# turn_time               :datetime
# type                    :string       STI
#

class Game < ApplicationRecord
  include Createable
  include Broadcastable

  enum status: { mulligan: 0, ongoing: 1, over: 2 }

  # ASSOCIATIONS ===========================================================

  # PLAYERS
  has_many :gamestate_decks
  has_many :players, class_name: :Player,
                     foreign_key: :game_id,
                     inverse_of: :game,
                     dependent: :destroy do
                       def in_mulligan?
                         status_mulligan.present?
                       end
                     end

  has_one :player_one, -> { where(turn_order: true) }, class_name: :Player
  has_one :player_two, -> { where(turn_order: false) }, class_name: :Player
  has_one :current_player, ->(game) { where(turn_order: game.turn) }, class_name: :Player

  has_many :cards, through: :players

  # ALIAS AND SCOPES ===========================================================

  # Input player, output opposing player in same game
  def opposing_player_of(player)
    player.turn_order ? player_two : player_one
  end

  # METHODS (PUBLIC) ==================================================================

  def begin_first_turn
    players.each(&:set_starting_hand)
    ongoing!
    animate_end_of_mulligan
    start_of_turn_actions
  end

  #========|Turn Changing|======
  # Current player cards lose attacking status
  # Game turn flips, current_player flips as a result
  # Current_player attributes updated for new turn
  def end_turn
    transaction do
      current_player.put_cards_to_sleep
      update(turn: !turn) and reload.current_player
      start_of_turn_actions
    end
  end

  #========|Party Card Play|======
  # Playing a card from hand to battlefield
  # Player must have enough gold to spend
  # Shifts position of cards to the right (increase position index) to make room for new card
  # Played card move from hand to battle in position

  # NOTE: TO SELF: THIS WOULD MAKE MORE SENSE TO MOVE TO THE CARD STI SUBCLASSES

  def play_card(card)
    transaction { card.enter_play if card.playable? }
  end

  #========|Party Card Battle|======
  # Card in attacking state may attack opponent card on battlefield
  # Broadcasts attack animation to opposing player of attacker
  # (Through use of Stimulus controller that connects to status attribute)
  # THEN updates health attributes of cards in battle and broadcasts to both players
  def conduct_attack(attacker, defender)
    with_lock { conduct_battle(attacker, defender) if attacker.can_attack?(defender) }
  end

  def add_dead_card(id)
    @dead_cards ||= []
    @dead_cards << id
  end

  # METHODS (PRIVATE) ==================================================================
  private

  ## GAMEPLAY RELATED PRIVATE FUNCTIONS

  def start_of_turn_actions
    current_player.prepare_new_turn if ongoing?
    update(turn_time: Time.now)
    broadcast_basic_update
  end

  # Update health of cards in battle
  def conduct_battle(attacker, defender)
    attacker.attack_enemy(defender)
    broadcast_battle_animations(attacker, defender, @dead_cards)
    broadcast_basic_update
  end
end
