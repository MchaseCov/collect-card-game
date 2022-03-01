class BattlecriesController < ApplicationController
  def targets
    battlecry = Battlecry.find(params[:id])
    game = Game.find(params[:game])
    render json: battlecry.find_target_options(game)
  end
end
