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
  def gamestate_cards
    party_card_gamestates # .or(action_card_gamestates);
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
end
