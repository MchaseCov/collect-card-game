#=======================================|CARD REFERENCE TABLE SCHEMA|=======================================
#
# table name: card_references
#
# id                      :bigint       null: false, primary key
# cost                    :integer
# attack                  :integer
# health                  :integer
# card_type               :string       NOT STI
# card_constant_id        :bigint       null: false, foreign key of card_constant data
# timestamps              :datetime
#
class CardReference < ApplicationRecord
  validates_presence_of :cost, :card_type, :card_constant_id
  validates_numericality_of :attack, :health
  validates :cost, numericality: { in: 0..10 }
  validates :card_type, inclusion: { in: %w[PartyCard SpellCard] }
  validates_uniqueness_of :card_constant_id

  belongs_to :card_constant
  has_many :account_deck_card_references
  has_many :account_decks, through: :account_deck_card_references
end
