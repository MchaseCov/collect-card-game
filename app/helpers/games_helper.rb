module GamesHelper
  def card_unplayable(card, player, game)
    (player.turn_order != game.turn) || (card.cost_current > player.cost_current)
  end
end
