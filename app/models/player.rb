#=======================================|PLAYER TABLE SCHEMA|=======================================
#
# table name: players
#
# id                      :bigint       null: false, primary key
# health_cap              :integer
# health_current          :integer
# cost_cap                :integer
# cost_current            :integer
# resource_cap            :integer
# resource_current        :integer
# turn_order              :boolean
# status                  :string
# attack_current          :integer
# race_id                 :bigint       null: false, foreign key of race
# archetype_id            :bigint       null: false, foreign key of archetype
# game_id                 :bigint       null: false, foreign key of game
# user_id                 :bigint       null: false, foreign key of user
#
class Player < ApplicationRecord
  #=======================================|CALLBACKS|==========================================
  after_create_commit do
    build_gamestate_deck(game: game, card_count: 30)
  end
  #=======================================|SCOPES|==========================================
  # scope :with_deck, -> { includes(:gamestate_deck) }

  validates_presence_of :health_cap, :health_current, :cost_cap, :cost_current, :resource_cap, :resource_current
  validates_numericality_of :health_cap, :cost_cap, :resource_cap
  validates :health_current, numericality: { less_than_or_equal_to: :health_cap }
  validates :cost_current, numericality: { less_than_or_equal_to: :cost_cap }
  validates :resource_current, numericality: { less_than_or_equal_to: :resource_cap }

  belongs_to :race
  belongs_to :archetype
  belongs_to :game
  belongs_to :user
  has_one :gamestate_deck, dependent: :destroy
  has_many :party_card_gamestates, through: :gamestate_deck

  # Method to use as futureproofing/reminder
  def cards
    party_card_gamestates # .or(action_card_gamestates);
  end

  def mulligan_cards
    party_card_gamestates.in_mulligan
  end

  def prepare_player(deck)
    race = deck.race
    archetype = deck.archetype
    health = (race.health_modifier + 30)
    cost = (race.cost_modifier + 1)
    resource = (race.resource_modifier + 1)
    update(
      health_cap: health,
      health_current: health,
      cost_cap: cost,
      cost_current: cost,
      resource_cap: resource,
      resource_current: resource,
      race: race,
      archetype: archetype,
      user: deck.user
    )
    save
  end

  def draw_mulligan_cards
    initial_draw = (turn_order ? 3 : 4)
    party_card_gamestates.in_mulligan.each(&:move_to_deck)
    party_card_gamestates.sample(initial_draw).each(&:move_to_mulligan)
  end

  def set_starting_hand
    party_card_gamestates.in_mulligan.each(&:move_to_hand)
    recount_deck_size
    game.update(status: 'ongoing') unless game.turn
  end

  def prepare_new_turn
    increment_player_resources
    wake_up_party_cards
    draw_cards(1)
    recount_deck_size
  end

  def spend_coins_on_card(card)
    return false if cost_current < card.cost_current

    decrement!(:cost_current, card.cost_current)
  end

  def put_cards_to_sleep
    party_card_gamestates.in_attack_mode.each(&:status_in_play)
  end

  def take_damage(attack)
    decrement!(:health_current, attack)
    health_current <= 0 ? game.update(status: 'over', ongoing: false) : update(status: 'default')
  end

  private

  def increment_player_resources
    increment!(:cost_cap) if cost_cap < 10
    increment!(:resource_cap) if resource_cap < 20
    # Interesting idea: What if resource does not replenish with turn and just goes up by X?
    update(cost_current: cost_cap, resource_current: resource_cap)
  end

  def draw_cards(amount)
    party_card_gamestates.in_deck.sample(amount).each(&:move_to_hand)
  end

  def recount_deck_size
    gamestate_deck.update(card_count: party_card_gamestates.in_deck.size)
  end

  def wake_up_party_cards
    party_card_gamestates.in_battle.each(&:set_to_attack)
  end
end
