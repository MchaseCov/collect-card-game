class GameQueueController < ApplicationController
  @@multiplayer_queue = []

  def self.queue
    @@multiplayer_queue
  end

  def view
    # POST for easy debug
    puts @@multiplayer_queue
  end

  def join
    return unless params[:deck_id] && queued_deck_is_playable

    add_player_to_queue
    ActionCable.server.broadcast("queue_#{current_user.id}", { "in_queue": true })
  end

  def leave
    remove_user_from_queue
    ActionCable.server.broadcast("queue_#{current_user.id}", { "exit_queue": true })
  end

  private

  def queued_deck_is_playable
    @queued_deck = AccountDeck.includes(:archetype, :race).find(params[:deck_id])
    @queued_deck.card_count == 30 && @queued_deck.user == current_user
  end

  def add_player_to_queue
    remove_user_from_queue
    queue_data = { user: current_user.id, deck: @queued_deck, time_entered: Time.now }
    @@multiplayer_queue << queue_data
    match_for_game if @@multiplayer_queue.size >= 2
  end

  def remove_user_from_queue
    @@multiplayer_queue.reject! { |entry| entry[:user] == current_user.id }
  end

  def match_for_game
    match_data = @@multiplayer_queue.sort_by { |entry| entry[:time_entered] }.first(2)
    game = MultiplayerGame.form_game(match_data.first[:deck], match_data.second[:deck])
    (@@multiplayer_queue -= match_data) && stream_started_game(game) if game
  end

  def stream_started_game(game)
    game.players.joins(:user).pluck('users.id').each do |id|
      ActionCable.server.broadcast("queue_#{id}", { game_formed: true, game_url: url_for(game) })
    end
  end
end
