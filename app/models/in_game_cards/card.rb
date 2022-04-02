#=======================================|CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: cards
#
# id                      :bigint       null: false, primary key
# cost                    :integer
# health                  :integer
# attack                  :integer
# health_cap              :integer
# location                :integer     enum
# status                  :integer     enum
# position                :integer
# silenced                :boolean
# type                    :string       STI reference column
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime
class Card < ApplicationRecord
  include Playable
  # Activate any observers tied to the card, such as a "when a spell is played" listener attatched to spell cards.
  after_update { active_listeners.each { |l| l.activate_listener_effect if l.listening_block.call(self) } }

  validates_presence_of :location, :type, :status
  validates :type, inclusion: { in: %w[PartyCard SpellCard] }
  validates :cost, numericality: { in: 0..10 }

  enum location: { deck: 0, hand: 1, mulligan: 2, battlefield: 3, graveyard: 4, discard: 5 }, _prefix: :in

  belongs_to :card_constant
  belongs_to :gamestate_deck
  has_one :player, through: :gamestate_deck
  has_one :game, through: :gamestate_deck
  has_many :active_buffs, as: :buffable, dependent: :destroy
  has_many :buffs, through: :active_buffs, after_add: :run_buff_method_on_card,
                   after_remove: :run_buff_removal_on_card
  has_many :active_listener_cards, dependent: :destroy
  has_many :active_listeners, through: :active_listener_cards
  alias_attribute :parent, :card_constant
  delegate :archetype, :name, :tribe, to: :card_constant
end
