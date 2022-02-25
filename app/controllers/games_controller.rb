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
    return unless current_users_turn && @player.cards.in_battle.size < 7

    card = @player.party_card_gamestates
                  .includes(:party_card_parent, :gamestate_deck, :archetype)
                  .find(params[:card_id])
    @game.put_card_in_play(card, params[:position].to_i, params[:battlecry_target])
  end

  def end_turn
    return unless current_users_turn && @game.status == 'ongoing'

    @game.end_turn
  end

  def minion_combat
    return unless current_users_turn

    attacking_card = @player.party_card_gamestates.in_attack_mode.find(params[:dragged_id])
    defending_card = @game.opposing_player_of(@player).party_card_gamestates.in_battle.find(params[:target_id])

    @game.conduct_attack(attacking_card, defending_card) if attacking_card && defending_card
  end

  def player_combat
    return unless current_users_turn && (@opposing_player.id == params[:target_id].to_i)

    attacking_card = @player.party_card_gamestates.in_attack_mode.find(params[:dragged_id])
    @game.conduct_attack(attacking_card, @opposing_player) if attacking_card
  end

  private

  def validate_decks_for_game_creation
    @queued_deck_one = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    @queued_deck_two = AccountDeck.includes(:archetype, :race).find(params[:deck_two_id])
    redirect_to root_path and return unless @queued_deck_one.card_count == 30 && @queued_deck_two.card_count == 30
  end

  def set_game_and_perspective
    @game = Game.find(params[:id])
    # Intended as a plan for spectating perspective but may not be compatible with actioncable turbo streaming
    @first_person_player = @game.players.find_by(user: current_user) || @game.player_one
    @opposing_player = @game.opposing_player_of(@first_person_player)
  end

  def conduct_mulligan
    # Safety check for if game is in mulligan but player does not have any mulligan cards.
    return if !current_users_turn || @player.mulligan_cards.any?

    @player.draw_mulligan_cards
  end

  def current_users_turn
    return false unless current_user == @game.current_player.user

    @player = @game.current_player
  end
end
