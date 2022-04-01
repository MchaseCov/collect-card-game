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
# silenced                :boolean
# type                    :string       STI reference column
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime

require './app/decorators/party_card_gamestate_decorator'

class Card < ApplicationRecord
  # ALIAS AND SCOPES ===========================================================
  alias_attribute :parent, :card_constant
  delegate :archetype, :name, :tribe, to: :card_constant

  # LOCATION SCOPES
  # in_hand, in_deck, in_mulligan, in_battle, in_graveyard, in_discard
  %i[hand deck mulligan battle graveyard discard].each do |location|
    scope "in_#{location}".to_sym, -> { where(location: location) }
  end

  # Activate any observers tied to the card, such as a "when a spell is played" listener attatched to spell cards.
  after_update do |card|
    card.active_listeners.each { |listener| listener.activate_listener_effect if listener.listening_block.call(card) }
  end

  # VALIDATIONS ===========================================================
  validates_presence_of :location, :type
  validates :type, inclusion: { in: %w[PartyCard SpellCard] }
  validates :cost, numericality: { in: 0..10 }

  # ASSOCIATIONS ===========================================================
  # CONSTANT CARD =
  belongs_to :card_constant
  # GAMESTATE DECK
  belongs_to :gamestate_deck
  # PLAYER
  has_one :player, through: :gamestate_deck
  # GAME
  has_one :game, through: :gamestate_deck
  # BUFFS
  has_many :active_buffs, as: :buffable, dependent: :destroy
  has_many :buffs, through: :active_buffs, after_add: :run_buff_method_on_card,
                   after_remove: :run_buff_removal_on_card

  # ACTIVE LISTENER OBSERVERS
  has_many :active_listener_cards, dependent: :destroy
  has_many :active_listeners, through: :active_listener_cards

  # Updates the location column of the Card.
  #
  # Examples
  #   card.move_to_battle
  #   # => UPDATE "cards" SET "location" = $1, "updated_at" = $2 WHERE "cards"."id" = $3
  #
  # Returns true if SQL transaction is successful.
  %i[hand deck mulligan battle graveyard discard].each do |location|
    define_method "move_to_#{location}".to_sym do
      update(location: location)
    end
  end
end
