module Broadcastable
  extend ActiveSupport::Concern

  included do
    def broadcast_to_players(broadcast_method, **data)
      players.each { |p| broadcast_method.call(p, **data) }
    end

    # rubocop:disable Metrics/MethodLength
    def broadcast_card_draw_animations(card)
      # rubocop:enable Metrics/MethodLength

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
      broadcast_to_players(method(:broadcast_animations), animation_data: card_draw_animation_data)
    end

    def broadcast_basic_update(last_played_card = nil)
      fetch_game_data
      broadcast_to_players(method(:broadcast_perspective_for), animation_data: last_played_card)
    end

    def broadcast_card_play_animations(card)
      broadcast_play_phase(card)
      card.type == 'PartyCard' ? broadcast_board_entry_phase(card) : fallback_entry_phase(card)
    end

    # rubocop:disable Metrics/MethodLength
    def broadcast_card_overdraw_animations(card)
      # rubocop:enable Metrics/MethodLength

      overdraw_animation_data = {
        targets: {
          target_one: {
            id: card.id,
            dataset: {
              'animationsTarget': 'overdrawnCard'
            }
          }
        },
        animationTime: 1
      }
      touch && fetch_game_data
      broadcast_to_players(method(:broadcast_animations), animation_data: overdraw_animation_data)
    end

    # rubocop:disable Metrics/MethodLength
    def broadcast_fatigue_draw_animations(player, damage_taken)
      # rubocop:enable Metrics/MethodLength

      fatigue_animation_data = {
        targets: {
          target_one: {
            id: player.id,
            dataset: {
              'animationsTarget': 'fatiguingPlayer',
              'damageTaken': damage_taken
            }
          }
        },
        animationTime: 1
      }
      touch && fetch_game_data
      broadcast_to_players(method(:broadcast_animations), animation_data: fatigue_animation_data)
    end

    private

    def fetch_game_data
      current_cache = Rails.cache.read("game_#{id}")
      if current_cache && current_cache[:game].updated_at == updated_at
        @game_data = current_cache
      else
        @game_data = return_cache_data
        Rails.cache.write("game_#{id}", @game_data, expires_in: 2.hours)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def broadcast_play_phase(card)
      # rubocop:enable Metrics/MethodLength
      from_hand_animation_data = {
        targets: {
          playedCard: { id: card.id,
                        dataset: { 'animationsTarget': 'fromHand',
                                   'targetPosition': (card.position&.-1 || 0) } }
        },
        animationTime: 0.6
      }

      if card.in_battlefield?
        cards_to_shift = card.player.cards.in_battlefield.pluck(:id, :position)
        cards_to_shift.map! { |c| { id: c[0], shift: c[1] > card.position ? 'shiftRight' : 'shiftLeft' } }
        from_hand_animation_data[:targets].tap do |targs|
          cards_to_shift.each { |c| targs[c[:id]] = { id: c[:id], dataset: { 'animationsTarget': c[:shift] } } }
        end
      end

      broadcast_to_players(method(:broadcast_animations), animation_data: from_hand_animation_data)
    end

    def broadcast_board_entry_phase(card)
      card_play_animation_data = { targets: {
        playedCard: { id: card.id, dataset: { 'animationsTarget': 'enterBattle' } }
      } }

      touch && fetch_game_data
      broadcast_to_players(method(:broadcast_animations), animation_data: card_play_animation_data, card: card)
    end

    def fallback_entry_phase(card)
      card_play_animation_data = { targets: {
        playedCard: { id: 'gameBoardParent', dataset: { 'animationsTarget': 'fallbackForEndShift' } }
      } }

      touch && fetch_game_data
      broadcast_to_players(method(:broadcast_animations), animation_data: card_play_animation_data, card: card)
    end

    def broadcast_battle_animations(attacker, defender)
      battle_animation_data = {
        targets: {
          target_one: { id: attacker.id, dataset: { 'animationsTarget': 'attacker' } },
          target_two: { id: defender.id, dataset: { 'animationsTarget': 'defender' } }
        },
        animationTime: 0.75
      }
      broadcast_to_players(method(:broadcast_animations), animation_data: battle_animation_data)
    end

    def animate_end_of_mulligan
      end_mulligan_data = {
        targets: {
          gameBoard: { id: 'gameBoardParent', dataset: { 'animationsTarget': 'endMulliganPhase' } }
        },
        animationTime: 3
      }

      broadcast_to_players(method(:broadcast_animations), animation_data: end_mulligan_data)
    end

    # Broadcast game data in JSON format over websocket to re-render with React.
    def broadcast_perspective_for(player, **data)
      fetch_game_data unless @game_data.present?
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data))
      game_json['lastPlayedCard'] = data[:card] if data[:card]
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'basicUpdate',
                                 gameData: game_json
                               })
    end

    # Broadcast animations by adding data attributes to objects through animation_object.
    # Will also pass along updated game data if @game_data is initialized before this call.
    def broadcast_animations(player, **data)
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data)) if @game_data
      game_json['lastPlayedCard'] = data[:card] if data[:card]
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'animation',
                                 animationData: data[:animation_data],
                                 gameData: game_json
                               })
    end
  end
end
