#=======================================|ACCOUNT DECK TABLE SCHEMA|=======================================
#
# table name: account_decks
#
# id                      :bigint       null: false, primary key
# name                    :string
# user_id                 :bigint       null: false, foreign key of User table
# card_count              :integer
# archetype_id            :bigint       null: false, foreign key of Archetype table
# race_id                 :bigint       null: false, foreign key of Race table
#
class AccountDeck < ApplicationRecord
  validates_presence_of :name
  validates :card_count, numericality: { in: 0..30 }

  has_many :account_deck_party_card_parents
  has_many :party_card_parents, through: :account_deck_party_card_parents
  belongs_to :user
  belongs_to :archetype
  belongs_to :race
end
