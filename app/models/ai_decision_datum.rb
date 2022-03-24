#=======================================|AI DECISION DATUM SCEHMA|=======================================
#
# table name: Ai_Decision_Data
#
# id                      :bigint       null: false, primary key
# type                    :string
# card_weight             :json
# card_constant_id  `     :bigint       FK of card constant`
#
class AiDecisionDatum < ApplicationRecord
  belongs_to :card_constant
end
