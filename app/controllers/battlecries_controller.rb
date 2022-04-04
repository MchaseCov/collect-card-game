class BattlecriesController < ApplicationController
  def targets
    battlecry = Battlecry.find(params[:id])
    card = Game.find(params[:game]).current_player.cards.first # Arbitrary
    render json: battlecry.find_target_options(card)
  end
end
