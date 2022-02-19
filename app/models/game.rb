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
    game = Game.find(id)
    broadcast_perspective_for(game.player_one)
    broadcast_perspective_for(game.player_two)
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
  def put_card_in_play(card, position)
    return unless current_player.spend_coins_on_card(card)

    card.player.cards.in_battle.where('position >= ?', position).each(&:increment_position)
    card.move_to_battle(position)
    card.battlecry.trigger(card) if card.battlecry.present?
    touch
  end

  #========|Party Card Battle|======
  # Card in attacking state may attack opponent card on battlefield
  # Broadcasts attack animation to opposing player of attacker
  # (Through use of Stimulus controller that connects to status attribute)
  # THEN updates health attributes of cards in battle and broadcasts to both players
  def conduct_attack(attacker, defender)
    return unless attacker.status == 'attacking'

    animate_attack_for_reciever(attacker, defender)
    deal_attack_damage(attacker, defender)
    touch
  end

  private

  # Updates status attribute for stimulus controller and broadcast
  def animate_attack_for_reciever(attacker, defender)
    attacker.update(status: 'currently_attacking')
    defender.update(status: 'currently_defending')
    broadcast_immediate_perspective_for((defender.is_a?(Player) ? defender : defender.player))
  end

  # Update health of cards in battle
  def deal_attack_damage(attacker, defender)
    defender.take_damage(attacker.attack_current)
    attacker.take_damage(defender.attack_current)
  end

  # Broadcast game over websocket
  def broadcast_perspective_for(player)
    broadcast_update_later_to [self, player.user], target: "game_#{id}_for_#{player.user.id}",
                                                   locals: { game: self,
                                                             first_person_player: player,
                                                             opposing_player: opposing_player_of(player) }
  end

  # Broadcast game over websocket SYNC. Use only in specific scenarios needing order of broadcast chains
  # i.e Broadcasting a gamestate before immedately updating gamestate so broadcast uses the original game state
  def broadcast_immediate_perspective_for(player)
    broadcast_update_to [self, player.user], target: "game_#{id}_for_#{player.user.id}",
                                             locals: { game: self,
                                                       first_person_player: player,
                                                       opposing_player: opposing_player_of(player) }
    sleep 0.2 # Prefer use of a JS listener to respond back to rails to request a broadcast, but this for now allows animations to complete before updating
  end
end
