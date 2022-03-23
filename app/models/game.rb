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
  # CALLBACKS ===========================================================
  # Builds a empty player object and assigns turn order for both players
  after_create_commit do
    @player_one = players.build(turn_order: true)
    @player_two = players.build(turn_order: false)
  end

  # ASSOCIATIONS ===========================================================

  # PLAYERS
  has_many :players, class_name: :Player,
                     foreign_key: :game_id,
                     inverse_of: :game,
                     dependent: :destroy do
                       def player_one
                         find_by('turn_order = true')
                       end

                       def player_two
                         find_by('turn_order = false')
                       end

                       def current_player(game)
                         find_by('turn_order = ?', game.turn)
                       end

                       def in_mulligan?
                         find_by(status: 'mulligan').present?
                       end
                     end

  # ALIAS AND SCOPES ===========================================================
  def player_one
    players.player_one
  end

  def player_two
    players.player_two
  end

  def current_player
    players.current_player(self)
  end

  # Input player, output opposing player in same game
  def opposing_player_of(player)
    players.find_by('id != ?', player.id)
  end

  # METHODS (PUBLIC) ==================================================================

  #========|Game Creation|======
  # Start of game creation. Input 2 decks. Output created
  def self.form_game(queued_deck_one, queued_deck_two)
    new_game = Game.create!
    new_game.send(:populate_players, queued_deck_one, queued_deck_two)
    new_game.send(:populate_decks, queued_deck_one, queued_deck_two)
    new_game.send(:draw_mulligan_cards) and return new_game
  end

  def begin_first_turn
    players.each(&:set_starting_hand)
    update(status: 'ongoing')
    animate_end_of_mulligan
    start_of_turn_actions
    broadcast_basic_update
  end

  #========|Turn Changing|======
  # Current player cards lose attacking status
  # Game turn flips, current_player flips as a result
  # Current_player attributes updated for new turn
  def end_turn
    current_player.put_cards_to_sleep
    update(turn: !turn) and reload.current_player
    start_of_turn_actions and broadcast_basic_update
  end

  #========|Party Card Play|======
  # Playing a card from hand to battlefield
  # Player must have enough gold to spend
  # Shifts position of cards to the right (increase position index) to make room for new card
  # Played card move from hand to battle in position

  # NOTE: TO SELF: THIS WOULD MAKE MORE SENSE TO MOVE TO THE CARD STI SUBCLASSES
  def play_party(card, position)
    return unless (current_player.party_cards.in_battle.size < 7) && current_player.spend_coins_on_card(card)

    broadcast_card_play_animations(card, position)
    card.player.cards.in_battle.where('position >= ?', position += 1).each(&:increment_position)
    card.put_card_in_battle(position)
    broadcast_basic_update(card)
  end

  def play_spell(card)
    # Return unless player sepdn resource points and then think of a broadcast here too.
    card.spend_spell
    broadcast_basic_update(card)
  end

  #========|Party Card Battle|======
  # Card in attacking state may attack opponent card on battlefield
  # Broadcasts attack animation to opposing player of attacker
  # (Through use of Stimulus controller that connects to status attribute)
  # THEN updates health attributes of cards in battle and broadcasts to both players
  def conduct_attack(attacker, defender)
    return unless attacker.status == 'attacking'

    dead_cards = deal_attack_damage(attacker, defender)
    broadcast_battle_animations(attacker, defender, dead_cards)

    broadcast_basic_update
  end

  def broadcast_card_draw_animations(card)
    touch
    broadcast_animations(card.player, 'fp_draw_card', { tag: 'fp', card: card })
    broadcast_animations(opposing_player_of(card.player), 'op_draw_card', { tag: 'op' })
  end

  def broadcast_basic_update(card = nil)
    touch
    broadcast_perspective_for(player_one, card)
    broadcast_perspective_for(player_two, card)
  end

  # METHODS (PRIVATE) ==================================================================
  private

  def broadcast_battle_animations(attacker, defender, dead_cards)
    touch
    players.each do |p|
      broadcast_animations(p, 'battle',
                           { attacker: { attacker.class.name => attacker.id },
                             defender: { defender.class.name => defender.id },
                             dead_cards: dead_cards })
    end
  end
  ## GAME CREATION RELATED PRIVATE FUNCTIONS

  # Takes previously built players and allows their model to fill attributes and save
  def populate_players(queued_deck_one, queued_deck_two)
    @player_one.prepare_player(queued_deck_one)
    @player_two.prepare_player(queued_deck_two)
  end

  # Takes previously built player model's game verison of decks and populates using queued deck data
  def populate_decks(queued_deck_one, queued_deck_two)
    @player_one.gamestate_deck.prepare_deck(queued_deck_one)
    @player_two.gamestate_deck.prepare_deck(queued_deck_two)
  end

  def draw_mulligan_cards
    players.each(&:draw_mulligan_cards)
  end

  ## GAMEPLAY RELATED PRIVATE FUNCTIONS

  def start_of_turn_actions
    current_player.prepare_new_turn if status == 'ongoing'
    update(turn_time: Time.now)
    broadcast_basic_update
  end

  # Update health of cards in battle
  def deal_attack_damage(attacker, defender)
    dead = []
    dead << defender.take_damage(attacker.attack)
    dead << attacker.take_damage(defender.attack)
    attacker.status_in_play
    dead.compact
  end

  ## BROADCAST RELATED PRIVATE FUNCTIONS

  def broadcast_card_play_animations(card, position)
    broadcast_animations(card.player, 'from_hand',
                         { hand: 'fp', played_card_id: card.id, target_id: position })
    broadcast_animations(opposing_player_of(card.player), 'from_hand',
                         { hand: 'op', played_card_id: card.id, target_id: position })
  end

  def animate_end_of_mulligan
    broadcast_animations(player_one, 'end_mulligan', { count: player_two.cards.in_hand.size })
    broadcast_animations(player_two, 'end_mulligan', { count: player_one.cards.in_hand.size })
  end

  # Broadcast game over websocket
  def broadcast_perspective_for(player, last_played_card = nil)
    broadcast_update_later_to [self, player.user], partial: 'games/game',
                                                   target: "game_#{id}_for_#{player.user.id}",
                                                   locals: { game: self,
                                                             first_person_player: player,
                                                             opposing_player: opposing_player_of(player),
                                                             last_played_card: last_played_card }
  end

  # Broadcast animations by streaming an update to a specific div that passes data to a Stimulus controller.
  # Current animation_type options:
  #
  # battle -- Animation for attackers meeting defenders and fighting
  # locals: { attacker: { attacker.class.name => attacker.id }, defender: { defender.class.name => defender.id } }
  #
  # from_hand -- Animation for cards being played from hand to the game board
  # locals: { hand: hand, played_card_id: played_card_id, target_id: target_id }
  #
  # [fp/op]_draw_card -- Animation for drawing a card from deck to hand
  # locals: { tag: tag, card: card }
  #
  # end_mulligan -- Animation for ending mulligan by moving cards from stage to hand and fading mulligan menu
  # locals: { count: count }
  #
  def broadcast_animations(player, animation_type, locals)
    broadcast_update_later_to [self, player.user], partial: "games/animations/#{animation_type}",
                                                   target: 'animation-data',
                                                   locals: locals
  end
end
