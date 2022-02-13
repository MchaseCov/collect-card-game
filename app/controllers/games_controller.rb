class GamesController < ApplicationController
  before_action :validate_decks_for_game_creation, only: [:create]
  before_action :set_game_and_perspective, except: [:create]
  before_action :conduct_mulligan, only: [:show], if: -> { @game.status == 'mulligan' }

  def show; end

  # Not 100% sure how queue and form will be designed yet
  def create
    @game = Game.form_game(@queued_deck_one, @queued_deck_two)
    redirect_to @game and return if @game

    redirect_to root_path
  end

  def submit_mulligan
    return unless current_users_turn

    @player.draw_mulligan_cards if params[:mulligan] # When player requests a new hand
    @player.set_starting_hand

    @game.end_turn
  end

  def play_card
    return unless params[:card_type] && params[:card_id] && current_users_turn

    # This looks like a strange check, but it's futureproof for "spell" cards
    card = @player.party_card_gamestates.in_hand.find(params[:card_id]) if params[:card_type] == 'Party'
    @game.put_card_in_play(card)
  end

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
    @opposing_player = @game.opposing_player_of(@first_person_player)
  end

  def conduct_mulligan
    return if !current_users_turn || @player.mulligan_cards.any?

    @player.draw_mulligan_cards
  end

  def current_users_turn
    return false unless current_user == @game.current_player.user

    @player = @game.current_player
  end
end
