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
  validates_uniqueness_of :card_constant_id

  def evaluate_targets(game)
    targets =
      case card_weight['target']
      when 'opponent_cards'
        game.human_player.party_cards.in_battlefield
      when 'opponent_player'
        game.human_player
      end
    targets.sample(card_weight['count'])
  end
end
