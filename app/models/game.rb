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
  #=======================================|CALLBACKS|==========================================
  # Builds a empty player object and assigns turn order for both players
  after_create_commit do
    @player_one = players.build(turn_order: true)
    @player_two = players.build(turn_order: false)
  end

  # Broadcasts over Websocket with a Turbo Stream response upon touch
  # Players have a seperate websocket connection which allows us to broadcast to only
  # one player at certain points to control the information the player sees about game state.
  after_touch do
    broadcast_perspective_for(player_one)
    broadcast_perspective_for(player_two)
  end

  #=======================================|GAME ASSOCIATIONS|=======================================

  #========|Game.players|======
  # Game has many players. Current player is when turn_order matches the game's turn
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
                     end

  # "Alias" methods for the above associations.
  # ie: @game.player_one as opposed to @game.players.player_one
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
    player == player_one ? player_two : player_one
  end

  #========|Game Winner|======
  # Assigns a winner directly to user account index.
  belongs_to :winner, optional: true,
                      class_name: :User,
                      foreign_key: :winner_id

  #=======================================|GAME METHODS|=====================================

  #========|Game Creation|======
  # Start of game creation. Input 2 decks. Output created
  def self.form_game(queued_deck_one, queued_deck_two)
    new_game = Game.create!
    new_game.populate_players(queued_deck_one, queued_deck_two)
    new_game.populate_decks(queued_deck_one, queued_deck_two)
    new_game
  end

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

  #========|Turn Changing|======
  # Current player cards lose attacking status
  # Game turn flips, current_player flips as a result
  # Current_player attributes updated for new turn
  def end_turn
    current_player.put_cards_to_sleep
    update(turn: !turn)
    reload.current_player

    start_of_turn_actions
    touch
  end

  def start_of_turn_actions
    current_player.prepare_new_turn if status == 'ongoing'
  end

  #========|Party Card Play|======
  # Playing a card from hand to battlefield
  # Player must have enough gold to spend
  # Shifts position of cards to the right (increase position index) to make room for new card
  # Played card move from hand to battle in position
  def put_card_in_play(card, position, target)
    return unless current_player.spend_coins_on_card(card)

    broadcast_card_play_animations(card, position)
    card.player.cards.in_battle.where('position >= ?', position += 1).each(&:increment_position)
    card.move_to_battle(position)
    card.battlecry.trigger(card, target) if card.battlecry.present?
    sleep 0.5
    players.each { |p| broadcast_perspective_for(p, card) }
  end

  #========|Party Card Battle|======
  # Card in attacking state may attack opponent card on battlefield
  # Broadcasts attack animation to opposing player of attacker
  # (Through use of Stimulus controller that connects to status attribute)
  # THEN updates health attributes of cards in battle and broadcasts to both players
  def conduct_attack(attacker, defender)
    return unless attacker.status == 'attacking'

    touch and return unless broadcast_battle_animations(attacker, defender)

    deal_attack_damage(attacker, defender)
    sleep 0.5
    touch
  end

  def broadcast_battle_animations(attacker, defender)
    players.each { |p| broadcast_animation_battle(p, attacker, defender) }
  end

  def broadcast_card_play_animations(card, position)
    broadcast_animation_played_card(card.player, 'fp', card.id, position)
    broadcast_animation_played_card(opposing_player_of(card.player), 'op', card.id, position)
  end

  private

  # Update health of cards in battle
  def deal_attack_damage(attacker, defender)
    defender.take_damage(attacker.attack_current)
    attacker.take_damage(defender.attack_current)
  end

  # Broadcast game over websocket
  def broadcast_perspective_for(player, last_played_card = nil)
    broadcast_update_later_to [self, player.user], target: "game_#{id}_for_#{player.user.id}",
                                                   locals: { game: self,
                                                             first_person_player: player,
                                                             opposing_player: opposing_player_of(player),
                                                             last_played_card: last_played_card }
  end

  # Broadcasts to the portion of the page that handles animation data for Stimulus. Passes no full objects, only IDs.
  # animations_controller.js does the work of interpreting and animating the data
  def broadcast_animation_battle(player, attacker, defender)
    broadcast_update_to [self, player.user], partial: 'games/animations/battle',
                                             target: 'animation-data',
                                             locals: { attacker: { attacker.class.name => attacker.id },
                                                       defender: { defender.class.name => defender.id } }
  end

  # Intentionally using seperate methods for different animation types to discourage overlap & messy optional args
  def broadcast_animation_played_card(player, hand, played_card_id, target_id)
    broadcast_update_to [self, player.user], partial: 'games/animations/from_hand',
                                             target: 'animation-data',
                                             locals: { hand: hand,
                                                       played_card_id: played_card_id,
                                                       target_id: target_id }
  end
end
