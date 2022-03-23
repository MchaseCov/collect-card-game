class SingleplayerGame < Game
  # HUGE NOT TO SELF: YOURE PROBABLY DOING A DEATH IN STIMULUS AND THEN STREAMING A DEATH BUT ALSO AN UPDATE BETWEEN THE DEATHS THAT MAKES THE CARD ALIVE AGIAN ITS WEIRD

  include SingleplayerAi

  alias_attribute :human_player, :player_one
  alias_attribute :ai_player, :player_two

  # METHODS (PUBLIC) ==================================================================

  #========|Game Creation|======
  # Start of game creation. Input 2 decks. Output created
  def self.form_game(queued_deck)
    new_game = SingleplayerGame.create!
    ai_deck = new_game.initialize_ai
    new_game.send(:populate_players, queued_deck, ai_deck)
    new_game.send(:populate_decks, queued_deck, ai_deck)
    new_game.send(:draw_mulligan_cards)
    new_game.ai_mulligan and return new_game
  end

  def broadcast_card_draw_animations(card)
    touch
    if card.player == human_player
      broadcast_animations('fp_draw_card', { tag: 'fp', card: card })
    else
      broadcast_animations('op_draw_card', { tag: 'op' })
    end
  end

  def broadcast_basic_update(card = nil)
    touch
    broadcast_perspective_for(card)
  end

  #========|Turn Changing|======
  # Current player cards lose attacking status
  # Game turn flips, current_player flips as a result
  # Current_player attributes updated for new turn
  def end_turn
    super
    begin_ai_turn if current_player == ai_player
  end

  # METHODS (PRIVATE) ==================================================================

  private

  ## BROADCAST RELATED PRIVATE FUNCTIONS

  def broadcast_battle_animations(attacker, defender, dead_cards)
    touch
    broadcast_animations('battle',
                         { attacker: { attacker.class.name => attacker.id },
                           defender: { defender.class.name => defender.id },
                           dead_cards: dead_cards })
  end

  def broadcast_card_play_animations(card, position)
    hand = card.player == human_player ? 'fp' : 'op'

    broadcast_animations('from_hand', { hand: hand, played_card_id: card.id, target_id: position })
  end

  def animate_end_of_mulligan
    broadcast_animations('end_mulligan', { count: ai_player.cards.in_hand.size })
  end

  # Broadcast game over websocket
  def broadcast_perspective_for(last_played_card = nil)
    broadcast_replace_later_to [self, human_player.user], partial: 'games/game',
                                                          target: "game_#{id}_for_#{human_player.user.id}",
                                                          locals: { game: self,
                                                                    first_person_player: human_player,
                                                                    opposing_player: ai_player,
                                                                    last_played_card: last_played_card }
  end

  def broadcast_animations(animation_type, locals)
    broadcast_update_later_to [self, human_player.user],
                              partial: "games/animations/#{animation_type}",
                              target: 'animation-data',
                              locals: locals
  end
end
