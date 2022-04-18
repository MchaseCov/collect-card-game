module Broadcastable
  extend ActiveSupport::Concern

  included do
    def broadcast_card_draw_animations(card)
      card_draw_animation_data = {
        targets: {
          target_one: {
            id: card.id,
            dataset: {
              'animationsTarget': 'drawnCard'
            }
          }
        }
      }
      touch && fetch_game_data
      players.each do |p|
        broadcast_animations(p, card_draw_animation_data)
      end
      # broadcast_animations(card.player, 'fp_draw_card', { tag: 'fp', card: card })
      # broadcast_animations(opposing_player_of(card.player), 'op_draw_card', { tag: 'op' })
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

    def broadcast_card_play_animations(card, _position = nil)
      broadcast_play_phase(card)
      broadcast_board_entry_phase(card)
    end

    private

    def broadcast_play_phase(card)
      from_hand_animation_data = {
        targets: {
          playedCard: { id: card.id,
                        dataset: { 'animationsTarget': 'fromHand',
                                   'targetPosition': (card.position ? card.position - 1 : 0) } }
        }
      }

      if card.in_battlefield?
        battlefield_cards = card.player.cards.in_battlefield
        left_cards = battlefield_cards.where('position < ?', card.position).pluck(:id)
        right_cards = battlefield_cards.where('position > ?', card.position).pluck(:id)
        left_targets = left_cards.map { |id| { id: id, dataset: { 'animationsTarget': 'shiftLeft' } } }
        right_targets = right_cards.map { |id| { id: id, dataset: { 'animationsTarget': 'shiftRight' } } }
        (left_targets + right_targets).each_with_index do |object, i|
          from_hand_animation_data[:targets][:"target_#{i}"] = object
        end
      end

      players.each do |p|
        broadcast_animations(p, from_hand_animation_data)
      end
    end

    def broadcast_board_entry_phase(card)
      card_play_animation_data = { targets: {
        playedCard: { id: card.id, dataset: { 'animationsTarget': 'enterBattle' } }
      } }

      touch && fetch_game_data
      players.each do |p|
        broadcast_animations(p, card_play_animation_data)
      end
    end

    def broadcast_battle_animations(attacker, defender, _dead_cards = nil)
      battle_animation_data = {
        targets: {
          target_one: { id: attacker.id, dataset: { 'animationsTarget': 'attacker' } },
          target_two: { id: defender.id, dataset: { 'animationsTarget': 'defender' } }
        }
      }
      players.each do |p|
        broadcast_animations(p, battle_animation_data)
      end
    end

    def animate_end_of_mulligan
      return
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
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data))
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'basicUpdate',
                                 gameData: game_json
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
    def broadcast_animations(player, animation_object) # , _animation_type, _locals)
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data)) if @game_data
      game_json['lastPlayedCard'] = @last_played_card if @last_played_card
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'animation',
                                 animationData: animation_object,
                                 gameData: game_json
                               })
    end
  end
end
