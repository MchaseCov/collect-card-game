#=======================================|PARTY CARD PARENT TABLE SCHEMA|=======================================
#
# table name: party_card_parents
#
# id                      :bigint       null: false, primary key
# name                    :string
# cost_default            :integer
# attack_default          :integer
# health_default          :integer
# tribe                   :string
# archetype_id            :sbigint      null: false, foreign key of archetype
# body                    :text
# timestamps              :datetime
#

class PartyCardParent < ApplicationRecord
  validates_presence_of :name, :cost_default, :attack_default, :health_default
  validates_uniqueness_of :name

  has_many :account_deck_party_card_parents
  has_many :account_decks, through: :account_deck_party_card_parents
  has_many :keywords
  belongs_to :archetype

  delegate :battlecry, :deathrattle, to: :keywords
end
