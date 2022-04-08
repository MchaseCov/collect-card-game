module Broadcastable
  extend ActiveSupport::Concern

  included do
    def broadcast_card_draw_animations(card)
      broadcast_animations(card.player, 'fp_draw_card', { tag: 'fp', card: card })
      broadcast_animations(opposing_player_of(card.player), 'op_draw_card', { tag: 'op' })
    end

    def broadcast_basic_update(card = nil)
      touch
      Rails.cache.delete("game_#{id}")
      Rails.cache.write("game_#{id}", return_cache_data, expires_in: 2.hours)
      @game_data = Rails.cache.read("game_#{id}")

      broadcast_perspective_for(player_one, card)
      broadcast_perspective_for(player_two, card)
    end

    def broadcast_card_play_animations(card, position)
      broadcast_animations(card.player, 'from_hand',
                           { hand: 'fp', played_card_id: card.id, target_id: position })
      broadcast_animations(opposing_player_of(card.player), 'from_hand',
                           { hand: 'op', played_card_id: card.id, target_id: position })
    end

    private

    def broadcast_battle_animations(attacker, defender, dead_cards)
      players.each do |p|
        broadcast_animations(p, 'battle',
                             { attacker: { attacker.class.name => attacker.id },
                               defender: { defender.class.name => defender.id },
                               dead_cards: dead_cards || [] })
      end
    end

    def animate_end_of_mulligan
      broadcast_animations(player_one, 'end_mulligan', { count: player_two.cards.in_hand.size })
      broadcast_animations(player_two, 'end_mulligan', { count: player_one.cards.in_hand.size })
    end

    def initialize_broadcast_variables(player)
      @first_person_player,
      @first_person_player_cards,
      @opposing_player,
      @opposing_player_cards,
      @opposing_player_cards_in_hand = curate_cache_for_perspective(player.user.id, @game_data).values
    end

    # Broadcast game over websocket
    def broadcast_perspective_for(player, last_played_card = nil)
      initialize_broadcast_variables(player)
      broadcast_update_later_to [self, player], partial: 'games/game',
                                                target: "game_#{id}_for_#{player.id}",
                                                locals: { game: self,
                                                          first_person_player: @first_person_player,
                                                          first_person_player_cards: @first_person_player_cards,
                                                          opposing_player: @opposing_player,
                                                          opposing_player_cards: @opposing_player_cards,
                                                          opposing_player_cards_in_hand: @opposing_player_cards_in_hand,
                                                          last_played_card: last_played_card }
    end

    # Broadcast animations by streaming an update to a specific div that passes data to a Stimulus controller.
    # Current animation_type options:
    #
    # battle -- Animation for attackers meeting defenders and fighting
    # locals: { attacker: { attacker.class.name => attacker.id }, defender: { defender.class.name => defender.id }, dead_cards: [dead_cards] }
    #
    # from_hand -- Animation for cards being played from hand to the game board
    # locals: { hand: hand, played_card_id: played_card_id, target_id: target_id }
    #
    # [fp/op]_draw_card -- Animation for drawing a card from deck to hand
    # locals: { tag: tag, card: card }
    #
    # end_mulligan -- Animation for ending mulligan by moving cards from stage to hand and fading mulligan menu
    # locals: { count: count }
    #
    def broadcast_animations(player, animation_type, locals)
      broadcast_update_later_to [self, player], partial: "games/animations/#{animation_type}",
                                                target: 'animation-data',
                                                locals: locals
    end
  end
end
