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
  belongs_to :card_constant
  has_many :account_deck_card_references
  has_many :account_decks, through: :account_deck_card_references
end
