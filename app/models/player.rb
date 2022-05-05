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
  include BoardPositionable
  include HasHealth
  include HasAttack

  enum status: {
    mulligan: 0, default: 1, attacking: 2, dead: 3
  }, _prefix: true

  # CALLBACKS ===========================================================
  after_create_commit do
    build_gamestate_deck(game: game, card_count: 30)
  end

  # ALIAS AND SCOPES ===========================================================
  validates_presence_of :cost_cap, :cost_current, :resource_cap, :resource_current, :status
  validates_numericality_of :cost_cap, :resource_cap, :cost_current, :health_cap
  validates :health_current, numericality: { less_than_or_equal_to: :health_cap }
  validates :resource_cap, numericality: { less_than_or_equal_to: 10 }
  validates :resource_current, numericality: { less_than_or_equal_to: :resource_cap }
  validates :attack, numericality: { greater_than_or_equal_to: 0 }

  validates :cost_cap, numericality: { less_than_or_equal_to: 10 }

  alias_attribute :health, :health_current
  # ASSOCIATIONS ===========================================================
  belongs_to :race
  belongs_to :archetype
  belongs_to :game
  belongs_to :user
  has_one :gamestate_deck, dependent: :destroy
  has_many :cards, through: :gamestate_deck
  has_many :party_cards, through: :gamestate_deck, source: :cards, class_name: :PartyCard
  has_many :spell_cards, through: :gamestate_deck, source: :cards, class_name: :SpellCard

  has_many :active_auras, as: :buffable, class_name: :ActiveBuff, dependent: :destroy
  has_many :auras, through: :active_auras, source: :buff, after_remove: :remove_aura_from_cards
  # METHODS (PUBLIC) ==================================================================

  def remove_aura_from_cards(aura)
    # This prevents duplicate auras from being deleted, but we have to manually send the callback too.
    cards.in_battlefield.each do |c|
      c.method(:deactivate_buff).call(aura) if c.active_buffs.find_by(buff_id: aura.id)&.destroy
    end
  end

  def draw_mulligan_cards
    initial_draw = (turn_order ? 3 : 4)
    cards.in_mulligan.each(&:in_deck!)
    cards.sample(initial_draw).each(&:in_mulligan!)
  end

  def set_starting_hand
    cards.includes(:gamestate_deck).in_mulligan.each(&:in_hand!)
    recount_deck_size
  end

  def prepare_new_turn
    increment_player_resources
    wake_up_party_cards
    draw_cards(1)
    recount_deck_size
  end

  def spend_coins_on_card(card)
    return false if cost_current < card.cost

    decrement!(:cost_current, card.cost)
  end

  def spend_resource_on_card(card)
    return false if resource_current < card.cost

    decrement!(:resource_current, card.cost)
  end

  def put_cards_to_sleep
    party_cards.includes(:card_constant, :gamestate_deck,
                         :active_listeners).in_battlefield.is_attacking.each(&:status_sleeping!)
  end

  def die
    game.update(status: 'over', ongoing: false)
  end

  def taunting_cards
    taunts = []
    party_cards.in_battlefield.where.associated(:buffs).uniq.each { |card| taunts << card if card.taunting? }
    taunts
  end

  def increment_cost_current(amount = 1)
    increment!(:cost_current, amount)
  end

  # Using an amount loop rather than .sample(amount) to burn individual cards
  def draw_cards(amount)
    amount.times do
      next take_empty_deck_fatigue if cards.in_deck.size <= 0

      topdeck = cards.includes(:card_constant, :gamestate_deck,
                               :active_listeners).in_deck.sample
      if cards.in_hand.size >= 10
        topdeck.in_overdraw!
        game.broadcast_card_overdraw_animations(topdeck)
      else
        topdeck.in_hand!
        game.broadcast_card_draw_animations(topdeck)
      end
    end
  end

  # METHODS (PRIVATE) ==================================================================
  private

  def increment_player_resources
    increment!(:cost_cap) if cost_cap < 10
    increment!(:resource_cap) if resource_cap < 10
    update(cost_current: cost_cap)
    increment!(:resource_current) unless resource_current == resource_cap
  end

  def recount_deck_size
    gamestate_deck.update(card_count: cards.in_deck.count)
  end

  def wake_up_party_cards
    party_cards.includes(:card_constant, :gamestate_deck,
                         :active_listeners).in_battlefield.each(&:status_attack_ready!)
  end
end
