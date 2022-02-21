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
  scope :in_mulligan, -> { where(location: 'mulligan') }
  scope :in_hand, -> { where(location: 'hand') }
  scope :in_deck, -> { where(location: 'deck') }
  scope :in_battle, -> { where(location: 'battle') }
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

  def move_to_hand
    update(location: 'hand')
  end

  def move_to_deck
    update(location: 'deck')
  end

  def move_to_mulligan
    update(location: 'mulligan')
  end

  def move_to_battle(position)
    update(location: 'battle', status: 'in_play', position: position)
  end

  def status_in_play
    update(status: 'in_play')
  end

  def set_to_attack
    update(status: 'attacking')
  end

  def set_to_graveyard
    update(location: 'graveyard', status: 'dead')
  end

  def increment_position
    increment!(:position)
  end

  def discard
    update(location: 'discard', status: 'discarded')
  end

  def take_damage(attack)
    decrement!(:health_current, attack)
    health_current <= 0 ? set_to_graveyard : status_in_play
  end

  def increase_health_cap(amount)
    increment!(:health_cap, amount)
    increment!(:health_current, amount)
  end
end
