module GamesHelper
  def card_unplayable(card, player, game)
    (player.turn_order != game.turn) || (card.cost_current > player.cost_current)
  end

  def turn_of?(player, game)
    player.turn_order == game.turn
  end
  
end
