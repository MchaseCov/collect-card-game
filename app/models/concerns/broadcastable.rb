module Broadcastable
  extend ActiveSupport::Concern

  included do
    def broadcast_card_draw_animations(card)
      broadcast_animations(card.player, 'fp_draw_card', { tag: 'fp', card: card })
      broadcast_animations(opposing_player_of(card.player), 'op_draw_card', { tag: 'op' })
    end

    def fetch_game_data
      current_cache = Rails.cache.read("game_#{id}")
      if current_cache && current_cache[:game].updated_at == updated_at
        @game_data = current_cache
      else
        @game_data = return_cache_data
        Rails.cache.write("game_#{id}", @game_data, expires_in: 2.hours)
      end
    end

    def broadcast_basic_update
      fetch_game_data
      players.each { |player| broadcast_perspective_for(player) }
      @last_played_card = nil
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
      @opposing_player_cards_in_hand = curate_cache_for_perspective(player.user.id,
                                                                    @game_data).values
    end

    # Broadcast game over websocket
    def broadcast_perspective_for(player)
      fetch_game_data unless @game_data.present?
      game_json = curate_json_for_perspective(player.user_id, @game_data)
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'basicUpdate',
                                 gameData: JSON.parse(game_json)
                               })
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
    def broadcast_animations(player, *_args) # , _animation_type, _locals)
      fetch_game_data unless @game_data.present?
      game_json = curate_json_for_perspective(player.user_id, @game_data)
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'animation',
                                 animationData: { targets: {
                                   target_one: {
                                     id: player_two.cards.in_battlefield.pluck(:id).first,
                                     animationTag: 'attacker'
                                   },
                                   target_two: {
                                     id: player_one.cards.in_battlefield.pluck(:id).first,
                                     animationTag: 'defender'
                                   }
                                 } }
                               })
    end
  end
end
