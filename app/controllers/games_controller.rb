class GamesController < ApplicationController
  def index; end

  def new; end

  def show
    @game = Game.includes(player_one: { gamestate_deck: :party_card_gamestates },
                          player_two: { gamestate_deck: :party_card_gamestates })
                .find(params[:id])
  end

  # Not 100% sure how queue and form will be designed yet
  def create
    validate_decks
    @game = Game.form_game(@queued_deck_one, @queued_deck_two)
    if @game
      redirect_to @game
    else
      redirect_to root_path
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def validate_decks
    @queued_deck_one = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    @queued_deck_two = AccountDeck.includes(:archetype, :race).find(params[:deck_two_id])
    redirect_to root_path and return unless @queued_deck_one.card_count == 30 && @queued_deck_two.card_count == 30
  end
end
