#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: party_card_parents
#
# id                      :bigint       null: false, primary key
# name                    :string
# cost_default            :integer
# attack_default          :integer
# health_default          :integer
# tribe                   :string
# group                   :string
# body                    :text
# timestamps              :datetime
#

class PartyCardParent < ApplicationRecord
end
