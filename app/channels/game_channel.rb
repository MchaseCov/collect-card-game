class GameChannel < ApplicationCable::Channel
  def subscribed
    @game = Game.find(params[:game])
    @player = @game.players.find(params[:player])
    stream_for([@game, @player])
    @game.method(:broadcast_perspective_for).call(@player)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
