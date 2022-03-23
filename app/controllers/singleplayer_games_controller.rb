class SingleplayerGamesController < GamesController
  before_action :current_users_turn, only: [:submit_mulligan]

  def create
    @game = SingleplayerGame.form_game(@queued_deck)
    redirect_to @game || root_path
  end

  def submit_mulligan
    return unless @player.status == 'mulligan'

    @player.draw_mulligan_cards if params[:mulligan] # When player requests a new hand
    @player.update(status: 'default')
    @game.begin_first_turn
  end

  private

  def set_game_and_perspective
    @game = SingleplayerGame.find(params[:id])
    @first_person_player = @game.player_one
    @opposing_player = @game.player_two
  end

  def conduct_mulligan
    # Safety check for if game is in mulligan but player does not have any mulligan cards.
    return if @first_person_player.mulligan_cards.any?

    @first_person_player.draw_mulligan_cards
  end

  def current_users_turn
    # In a single player game, it's "always" the real player's turn
    head(401) unless current_user == @first_person_player.user

    @player = @first_person_player
  end

  def validate_decks_for_game_creation
    @queued_deck = AccountDeck.includes(:archetype, :race).find(params[:deck_one_id])
    redirect_to root_path and return if @queued_deck.card_count != 30
  end
end
