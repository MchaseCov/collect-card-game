module Createable
  extend ActiveSupport::Concern

  included do
    # CALLBACKS ===========================================================
    # Builds a empty player object and assigns turn order for both players
    after_create_commit do
      @player_one = players.build(turn_order: true)
      @player_two = players.build(turn_order: false)
    end

    def begin_game(queued_deck_one, queued_deck_two)
      @queued_deck_one = queued_deck_one
      @queued_deck_two = queued_deck_two
      populate_players
      populate_decks
      draw_mulligan_cards
    end

    private

    # Takes previously built players and allows their model to fill attributes and save
    def populate_players
      @player_one.prepare_player(@queued_deck_one)
      @player_two.prepare_player(@queued_deck_two)
    end

    # Takes previously built player model's game verison of decks and populates using queued deck data
    def populate_decks
      @player_one.gamestate_deck.prepare_deck(@queued_deck_one)
      @player_two.gamestate_deck.prepare_deck(@queued_deck_two)
    end

    def draw_mulligan_cards
      players.each(&:draw_mulligan_cards)
    end
  end

  class_methods do
    def form_game(queued_deck_one, queued_deck_two)
      new_game = Game.create!
      new_game.begin_game(queued_deck_one, queued_deck_two)
      new_game
    end
  end
end
