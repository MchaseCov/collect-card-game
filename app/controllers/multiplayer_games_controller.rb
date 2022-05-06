class MultiplayerGamesController < GamesController
  private

  def set_game
    super
    head(400) unless @game.type == 'MultiplayerGame'
  end
end
