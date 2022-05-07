module HasAi
  extend ActiveSupport::Concern

  included do
    private

    def do_ai_mulligan
      ai_player.update(status: 'default')
      ai_party_cards_cost = ai_player.party_cards.in_mulligan.pluck(:cost)
      # Ai will keep their hand if they have at least 2 party cards where one is playable on turn 2.
      return if ai_party_cards_cost.length >= 2 && ai_party_cards_cost.min <= 2

      ai_player.draw_mulligan_cards
    end

    def ai_take_turn
      analyze_current_gamestate
      determine_ai_options
      ai_turn_cycle if @ai_options.any? { |_k, v| v }
      end_turn
    end

    def determine_ai_options
      @ai_options = {
        ai_has_playable_party_cards: ai_has_playable_party_cards?,
        ai_has_attacking_card_in_play: ai_has_attacking_card_in_play?
      }
    end

    def ai_turn_cycle
      sleep 2
      ai_decide_a_play
      determine_ai_options
      ai_turn_cycle if @ai_options.any? { |_k, v| v }
    end

    def ai_decide_a_play
      return ai_play_a_party_card if @ai_options[:ai_has_playable_party_cards]
      return ai_attack_a_target if @ai_options[:ai_has_attacking_card_in_play]
    end

    def analyze_current_gamestate
      @ai_health_score = 2 * Math.sqrt(ai_player.health_current)
      @player_health_score = 2 * Math.sqrt(human_player.health_current)
      @ai_hand_score = (1..ai_player.cards.in_hand.size).each.inject(0) { |sum, num| sum + (num <= 4 ? 3 : 2) }
      @player_hand_score = (1..human_player.cards.in_hand.size).each.inject(0) { |sum, num| sum + (num <= 4 ? 3 : 2) }
    end

    def ai_endangered?
      (human_player.cards.in_battlefield.pluck(:attack).sum >= (0.8 * ai_player.health_current))
    end

    def ai_is_losing_tempo?
      ai_stats_in_play = ai_player.cards.in_battlefield.pluck(:attack, :health).flatten.sum.to_f
      human_stats_in_play = human_player.cards.in_battlefield.pluck(:attack, :health).flatten.sum
      (human_stats_in_play / ai_stats_in_play + 0.01) >= 1.6
    end

    def ai_has_playable_party_cards?
      return false if ai_player.party_cards.in_battlefield.size >= 7

      @playable_party_cards = ai_player.party_cards.in_hand.where('cost <= ?', ai_player.cost_current)
      @playable_party_cards.any?
    end

    def ai_has_attacking_card_in_play?
      @attack_ready_cards = ai_player.party_cards.in_battlefield.status_attack_ready
      @attack_ready_cards.any?
    end

    def ai_play_a_party_card
      analyzed_card = @playable_party_cards.sample
      max_position = ai_player.party_cards.in_battlefield&.pluck(:position)&.max || 1
      chosen_position = rand(1..max_position)
      analyzed_card.chosen_position = chosen_position
      play_card(analyzed_card)
    end

    def ai_attack_a_target
      valid_targets =
        if human_player.taunting_cards.any?
          human_player.taunting_cards
        elsif ai_endangered?
          human_player.party_cards.in_battlefield
        else
          human_player.party_cards.in_battlefield + [human_player]
        end

      target_to_attack = valid_targets.sample
      attacker = @attack_ready_cards.where('attack >= ?',
                                           target_to_attack.health).order(:attack).first || @attack_ready_cards.order(:attack).last
      conduct_attack(attacker, target_to_attack)
    end
  end

  class_methods do
    def ai_user_account
      User.find_by(email: 'collectablecardgameai@gmail.com')
    end

    def ai_default_deck
      ai_user_account.account_decks.first
    end
  end
end
