class SingleplayerGame < Game
  include HasAi

  alias_attribute :human_player, :player_one
  alias_attribute :ai_player, :player_two

  # METHODS (PUBLIC) ==================================================================

  def self.form_game(queued_deck_one, queued_deck_two = ai_default_deck)
    new_game = SingleplayerGame.create!
    new_game.begin_game(queued_deck_one, queued_deck_two)
    new_game
  end

  def begin_game(queued_deck_one, queued_deck_two)
    super
    reload
    ai_player.user = self.class.ai_user_account
    do_ai_mulligan
  end

  #========|Turn Changing|======
  # Current player cards lose attacking status
  # Game turn flips, current_player flips as a result
  # Current_player attributes updated for new turn
  def end_turn
    super
    ai_take_turn if current_player == ai_player
  end

  # METHODS (PRIVATE) ==================================================================

  private

  def broadcast_to_players(broadcast_method, **data)
    broadcast_method.call(human_player, **data)
  end
end
