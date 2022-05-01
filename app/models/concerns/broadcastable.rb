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
    end

    def broadcast_basic_update(last_played_card = nil)
      fetch_game_data
      players.each { |player| broadcast_perspective_for(player, last_played_card) }
    end

    def broadcast_card_play_animations(card)
      broadcast_play_phase(card)
      card.type == 'PartyCard' ? broadcast_board_entry_phase(card) : fallback_entry_phase(card)
    end

    def broadcast_card_overdraw_animations(card)
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
      players.each do |p|
        broadcast_animations(p, overdraw_animation_data)
      end
    end

    def broadcast_fatigue_draw_animations(player, damage_taken)
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
      players.each do |p|
        broadcast_animations(p, fatigue_animation_data)
      end
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

    def broadcast_play_phase(card)
      from_hand_animation_data = {
        targets: {
          playedCard: { id: card.id,
                        dataset: { 'animationsTarget': 'fromHand',
                                   'targetPosition': (card.position ? card.position - 1 : 0) } }
        },
        animationTime: 0.6
      }

      if card.in_battlefield?
        left_cards = card.player.cards.in_battlefield.where('position < ?', card.position)
        right_cards = card.player.cards.in_battlefield.where('position > ?', card.position)
        left_cards.pluck(:id).each do |id|
          from_hand_animation_data[:targets][:"target_#{id}"] =
            { id: id, dataset: { 'animationsTarget': 'shiftLeft' } }
        end
        right_cards.pluck(:id).each do |id|
          from_hand_animation_data[:targets][:"target_#{id}"] =
            { id: id, dataset: { 'animationsTarget': 'shiftRight' } }
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
        broadcast_animations(p, card_play_animation_data, card)
      end
    end

    def fallback_entry_phase(card)
      card_play_animation_data = { targets: {
        playedCard: { id: 'gameBoardParent', dataset: { 'animationsTarget': 'fallbackForEndShift' } }
      } }

      touch && fetch_game_data
      players.each do |p|
        broadcast_animations(p, card_play_animation_data, card)
      end
    end

    def broadcast_battle_animations(attacker, defender, _dead_cards = nil)
      battle_animation_data = {
        targets: {
          target_one: { id: attacker.id, dataset: { 'animationsTarget': 'attacker' } },
          target_two: { id: defender.id, dataset: { 'animationsTarget': 'defender' } }
        },
        animationTime: 0.75
      }
      players.each do |p|
        broadcast_animations(p, battle_animation_data)
      end
    end

    def animate_end_of_mulligan
      end_mulligan_data = {
        targets: {
          gameBoard: { id: 'gameBoardParent', dataset: { 'animationsTarget': 'endMulliganPhase' } }
        },
        animationTime: 3
      }

      players.each do |p|
        broadcast_animations(p, end_mulligan_data)
      end
    end

    def initialize_broadcast_variables(player)
      @first_person_player,
      @first_person_player_cards,
      @opposing_player,
      @opposing_player_cards,
      @opposing_player_cards_in_hand = curate_cache_for_perspective(player.user.id,
                                                                    @game_data).values
    end

    # Broadcast game data in JSON format over websocket to re-render with React.
    def broadcast_perspective_for(player, last_played_card = nil)
      fetch_game_data unless @game_data.present?
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data))
      game_json['lastPlayedCard'] = last_played_card if last_played_card
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'basicUpdate',
                                 gameData: game_json
                               })
    end

    # Broadcast animations by adding data attributes to objects through animation_object.
    # Will also pass along updated game data if @game_data is initialized before this call.
    def broadcast_animations(player, animation_object, last_played_card = nil)
      game_json = JSON.parse(curate_json_for_perspective(player.user_id, @game_data)) if @game_data
      game_json['lastPlayedCard'] = last_played_card if last_played_card
      GameChannel.broadcast_to([self, player], {
                                 streamPurpose: 'animation',
                                 animationData: animation_object,
                                 gameData: game_json
                               })
    end
  end
end
