class GamesController < ApplicationController
  before_action :validate_decks_for_game_creation, only: [:create]
  before_action :set_game, except: [:create]
  before_action :set_perspective, only: [:show]
  before_action :conduct_mulligan, only: [:show], if: -> { @game.status == 'mulligan' }
  before_action :current_users_turn, only: %i[play_party play_spell end_turn party_combat player_combat]

  def show; end

  # Not 100% sure how queue and form will be designed yet
  def create
    @game = Game.form_game(@queued_deck_one, @queued_deck_two)
    redirect_to @game || root_path
  end

  def submit_mulligan
    @player = @game.players.find_by(user: current_user)
    # "Turns" do not take effect yet, so we don't use the current_users_turn gat

    return unless @player&.status_mulligan?

    @player.draw_mulligan_cards if params[:mulligan] # When player requests a new hand
    @player.status_default!
    @game.players.in_mulligan? ? @game.broadcast_basic_update : @game.begin_first_turn
  end

  def play_party
    return unless params[:position]

    party = @player.party_cards
                   .includes(:card_constant, :gamestate_deck)
                   .find(params[:card])
    party.current_target = params[:target].to_i if params[:target]
    party.chosen_position = params[:position].to_i + 1

    @game.play_card(party)
  end

  def play_spell
    spell = @player.spell_cards
                   .includes(:card_constant, :gamestate_deck)
                   .find(params[:card])
    spell.current_target = params[:target].to_i if params[:target]
    @game.play_card(spell)
  end

  def end_turn
    @game.end_turn if @game.ongoing?
  end

  def party_combat
    attacking_card = @player.party_cards.in_battlefield.is_attacking.find(params[:card])
    defending_card = @game.opposing_player_of(@player).party_cards.in_battlefield.find(params[:target])

    @game.conduct_attack(attacking_card, defending_card) if attacking_card && defending_card
  end

  def player_combat
    return unless @opposing_player.id == params[:target].to_i

    attacking_card = @player.party_cards.in_battlefield.is_attacking.find(params[:card])
    @game.conduct_attack(attacking_card, @opposing_player) if attacking_card
  end

  private

  def validate_decks_for_game_creation
    @queued_deck_one = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    @queued_deck_two = AccountDeck.includes(:archetype, :race).find(params[:deck_two_id])
    redirect_to root_path and return if @queued_deck_one.card_count != 30 || @queued_deck_two.card_count != 30
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def set_perspective
    # Intended as a plan for spectating perspective but may not be compatible with actioncable turbo streaming
    @first_person_player = @game.players.find_by(user: current_user) || @game.player_one
    @opposing_player = @game.opposing_player_of(@first_person_player)
  end

  def conduct_mulligan
    @player = @game.players.find_by(user: current_user)
    # Safety check for if game is in mulligan but player does not have any mulligan cards.
    return if @player.cards.in_mulligan.any?

    @player.draw_mulligan_cards
  end

  def current_users_turn
    head(401) unless current_user == @game.current_player.user

    @player = @game.current_player
  end
end
