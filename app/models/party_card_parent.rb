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
# archetype               :string
# body                    :text
# timestamps              :datetime
#

class PartyCardParent < ApplicationRecord
  has_and_belongs_to_many :account_decks

  validates_presence_of :name, :cost_default, :attack_default, :health_default, :tribe, :archetype
end
