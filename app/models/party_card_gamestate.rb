#=======================================|PARTY CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: party_card_gamestates
#
# id                      :bigint       null: false, primary key
# health_cap              :integer
# health_current          :integer
# cost_current            :integer
# attack_cap              :integer
# attack_current          :integer
# location                :string
# status                  :string
# position                :integer
# archetype_id            :bigint       null: false, foreign key
# party_card_parent_id    :bigint       null: false, foreign key
# gamestate_deck_id       :bigint       null: false, foreign key
# timestamps              :datetime

class PartyCardGamestate < ApplicationRecord
  alias_attribute :parent, :party_card_parent
  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { includes(:party_card_parent).where('party_card_parent.tribe': tribe) }
  end
  %i[hand deck mulligan battle graveyard discard].each do |location|
    scope "in_#{location}".to_sym, -> { where(location: location) }
  end
  %i[in_play attacking dead discarded].each do |status|
    scope "is_#{status}".to_sym, -> { where(status: status) }
  end
  scope :in_attack_mode, -> { where(location: 'battle', status: 'attacking') }

  validates_presence_of :health_cap, :health_current, :cost_current, :attack_cap, :attack_current,
                        :location, :status
  validates_numericality_of :health_cap, :attack_cap
  validates :health_current, numericality: { less_than_or_equal_to: :health_cap }
  validates :cost_current, numericality: { in: 0..10 }
  validates :attack_current, numericality: { less_than_or_equal_to: :attack_cap }

  belongs_to :archetype
  belongs_to :party_card_parent
  belongs_to :gamestate_deck

  has_one :player, through: :gamestate_deck
  has_one :game, through: :gamestate_deck

  delegate :battlecry, :deathrattle, :keywords, to: :party_card_parent

  %i[hand deck mulligan battle graveyard discard].each do |location|
    define_method "move_to_#{location}".to_sym do
      update(location: location)
    end
  end

  %i[in_play attacking dead discarded].each do |status|
    define_method "status_#{status}".to_sym do
      update(status: status)
    end
  end

  %i[position health_cap health_current].each do |attribute|
    define_method "increment_#{attribute}".to_sym do |amount = 1|
      increment!(attribute, amount)
    end
    define_method "decrement_#{attribute}".to_sym do |amount = 1|
      decrement!(attribute, amount)
    end
  end

  def put_card_in_battle(position)
    move_to_battle
    status_in_play
    update(position: position)
  end

  def take_damage(attack)
    decrement_health_current(attack)
    put_card_in_graveyard and return id if health_current <= 0
  end

  def increase_health_cap(amount)
    increment_health_cap(amount) and increment_health_current(amount)
  end

  private

  def put_card_in_graveyard
    player.cards.in_battle.where('position >= ?', position).each(&:decrement_position)
    move_to_graveyard and status_dead
  end
end
