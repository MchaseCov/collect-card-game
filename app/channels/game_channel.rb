class GameChannel < ApplicationCable::Channel
  def subscribed
    game_data = Rails.cache.fetch("game_#{params[:game]}", expires_in: 2.hours) do
      Game.find(params[:game]).return_cache_data
    end
    @game = game_data[:game]
    @player = @game.players.find(params[:player])
    stream_for([@game, @player])
    @game.method(:broadcast_perspective_for).call(@player)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
