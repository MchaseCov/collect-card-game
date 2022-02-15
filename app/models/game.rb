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

  after_touch do
    game = Game.with_players_and_decks.find(id)
    broadcast_perspective_for(game.player_one)
    broadcast_perspective_for(game.player_two)
  end
  #=======================================|SCOPES|==========================================

  scope :with_players_and_decks, -> { includes(player_one: :gamestate_deck, player_two: :gamestate_deck) }

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

  def opposing_player_of(player)
    player == player_one ? player_two : player_one
  end

  def self.form_game(queued_deck_one, queued_deck_two)
    new_game = Game.create!
    new_game.populate_players(queued_deck_one, queued_deck_two)
    new_game.populate_decks(queued_deck_one, queued_deck_two)
    new_game
  end

  def end_turn
    current_player.put_cards_to_sleep
    update(turn: !turn)
    reload.current_player

    start_of_turn_actions
    touch
  end

  def put_card_in_play(card, position)
    return unless current_player.spend_coins_on_card(card)

    card.player.cards.in_battle.where('position >= ?', position).each(&:increment_position)
    card.move_to_battle(position)
    touch
  end

  def populate_players(queued_deck_one, queued_deck_two)
    player_one.prepare_player(queued_deck_one)
    player_two.prepare_player(queued_deck_two)
  end

  def populate_decks(queued_deck_one, queued_deck_two)
    player_one.gamestate_deck.prepare_deck(queued_deck_one)
    player_two.gamestate_deck.prepare_deck(queued_deck_two)
  end

  def conduct_attack(attacking_card, defending_card)
    return unless attacking_card.status == 'attacking'

    animate_attack_for_reciever(attacking_card, defending_card)
    deal_attack_damage(attacking_card, defending_card)
    touch
  end

  private

  def animate_attack_for_reciever(attacking_card, defending_card)
    attacking_card.update(status: 'currently_attacking')
    defending_card.update(status: 'currently_defending')
    broadcast_immediate_perspective_for(defending_card.player)
  end

  def deal_attack_damage(attacking_card, defending_card)
    defending_card.take_damage(attacking_card.attack_current)
    attacking_card.take_damage(defending_card.attack_current)
  end

  def start_of_turn_actions
    current_player.prepare_new_turn if status == 'ongoing'
  end

  def broadcast_perspective_for(player)
    broadcast_update_later_to [self, player.user], target: "game_#{id}_for_#{player.user.id}", locals: { game: self,
                                                                                                         first_person_player: player,
                                                                                                         opposing_player: opposing_player_of(player) }
  end

  def broadcast_immediate_perspective_for(player)
    broadcast_update_to [self, player.user], target: "game_#{id}_for_#{player.user.id}", locals: { game: self,
                                                                                                   first_person_player: player,
                                                                                                   opposing_player: opposing_player_of(player) }
  end
end
