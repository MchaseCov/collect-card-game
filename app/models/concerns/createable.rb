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
      prepare_player(@player_one, @queued_deck_one)
      prepare_player(@player_two, @queued_deck_two)
    end

    # Takes previously built player model's game verison of decks and populates using queued deck data
    def populate_decks
      prepare_deck(@player_one.gamestate_deck, @queued_deck_one)
      prepare_deck(@player_two.gamestate_deck, @queued_deck_two)
    end

    def draw_mulligan_cards
      players.each(&:draw_mulligan_cards)
    end

    def prepare_player(player, deck)
      race = deck.race
      archetype = deck.archetype
      health = (race.health_modifier + 30)
      cost = race.cost_modifier
      resource = race.resource_modifier
      player.update(health_cap: health, health_current: health, cost_cap: cost, cost_current: cost,
                    resource_cap: resource, resource_current: resource, race: race, archetype: archetype,
                    user: deck.user, status: 'mulligan')
      player.save
    end

    def prepare_deck(gamestate_deck, queued_deck)
      queued_deck.card_references.includes(:card_constant).each do |card|
        gamestate_deck.cards.create!(cost: card.cost, health: card.health, attack: card.attack,
                                     health_cap: card.health, location: 'deck', status: 'unplayed',
                                     type: card.card_type, card_constant: card.card_constant)
      end
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
