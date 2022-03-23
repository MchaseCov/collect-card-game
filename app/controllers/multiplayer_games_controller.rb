class MultiplayerGamesController < GamesController
  private

  def set_game_and_perspective
    @game = MultiplayerGame.find(params[:id])
    # Intended as a plan for spectating perspective but may not be compatible with actioncable turbo streaming
    @first_person_player = @game.players.find_by(user: current_user) || @game.player_one
    @opposing_player = @game.opposing_player_of(@first_person_player)
  end
end
