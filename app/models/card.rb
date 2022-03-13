#=======================================|CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: cards
#
# id                      :bigint       null: false, primary key
# cost                    :integer
# health                  :integer
# attack                  :integer
# health_cap              :integer
# location                :string
# status                  :string
# position                :integer
# type                    :string       STI reference column
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime

require './app/decorators/party_card_gamestate_decorator'

class Card < ApplicationRecord
  # ALIAS AND SCOPES ===========================================================
  alias_attribute :parent, :card_constant

  # LOCATION
  %i[hand deck mulligan battle graveyard discard].each do |location|
    scope "in_#{location}".to_sym, -> { where(location: location) }
  end
  scope :in_attack_mode, -> { where(location: 'battle', status: 'attacking') }

  # VALIDATIONS ===========================================================
  validates_presence_of :location, :type
  validates :type, inclusion: { in: %w[PartyCard SpellCard] }
  validates :cost, numericality: { in: 0..10 }

  # ASSOCIATIONS ===========================================================
  # CONSTANT CARD
  belongs_to :card_constant
  # GAMESTATE DECK
  belongs_to :gamestate_deck
  # PLAYER
  has_one :player, through: :gamestate_deck
  # GAME
  has_one :game, through: :gamestate_deck
  # KEYWORDS
  delegate :battlecry, :deathrattle, :keywords, to: :card_constant
  # BUFFS
  has_many :active_buffs, as: :buffable
  has_many :buffs, through: :active_buffs, after_add: :run_buff_method_on_card,
                   after_remove: :run_buff_removal_on_card

  # UPDATE METHODS ===========================================================
  # LOCATION
  %i[hand deck mulligan battle graveyard discard].each do |location|
    define_method "move_to_#{location}".to_sym do
      update(location: location)
    end
  end
end
