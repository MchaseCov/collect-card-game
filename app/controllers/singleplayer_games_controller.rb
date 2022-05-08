class SingleplayerGamesController < GamesController
  before_action :current_users_turn, only: [:submit_mulligan]

  def create
    @game = SingleplayerGame.form_game(@queued_deck)
    redirect_to @game || root_path
  end

  def submit_mulligan
    player = @game.players.find_by(user: current_user)

    return unless player&.status_mulligan?

    player.draw_mulligan_cards if params[:mulligan] # When player requests a new hand
    player.status_default!
    @game.touch && @game.begin_first_turn
  end

  private

  def validate_decks_for_game_creation
    redirect_to root_path and return unless params[:deck_one_id]

    @queued_deck = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    redirect_to root_path and return if @queued_deck.card_count != 30
  end

  def set_game
    super
    head(400) unless @game.type == 'SingleplayerGame'
  end
end
