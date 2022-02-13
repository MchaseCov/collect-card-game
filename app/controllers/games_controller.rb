class GamesController < ApplicationController
  before_action :validate_decks_for_game_creation, only: [:create]
  before_action :set_game_and_perspective, only: %i[show submit_mulligan]

  def show; end

  # Not 100% sure how queue and form will be designed yet
  def create
    @game = Game.form_game(@queued_deck_one, @queued_deck_two)
    redirect_to @game and return if @game

    redirect_to root_path
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def validate_decks_for_game_creation
    @queued_deck_one = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    @queued_deck_two = AccountDeck.includes(:archetype, :race).find(params[:deck_two_id])
    redirect_to root_path and return unless @queued_deck_one.card_count == 30 && @queued_deck_two.card_count == 30
  end

  def set_game_and_perspective
    @game = Game.with_players_and_decks.find(params[:id])
    # Intended as a plan for spectating perspective but may not be compatible with actioncable turbo streaming
    @first_person_player = @game.players.find_by(user: current_user) || @game.player_one
  end

  def current_users_turn
    return false unless current_user == @game.current_player.user

    @player = @game.current_player
  end
end
