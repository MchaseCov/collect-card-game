class AiCardAdvantage < AiDecisionDatum
  def evaluate_weight_of_card(game)
    in_hand_amount = game.ai_player.cards.in_hand.size
    card_draw_score = card_weight['count'] * 5
    need_for_draw = 50 - (in_hand_amount * 5)
    card_draw_score + need_for_draw
  end
end
