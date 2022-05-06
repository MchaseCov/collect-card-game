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

    def begin_ai_turn
      sleep 1
      @ai_has_playable_party_cards = ai_has_playable_party_cards?
      ai_play_a_party_card while @ai_has_playable_party_cards
      end_turn
    end

    def ai_has_playable_party_cards?
      return false if ai_player.party_cards.in_battlefield.size <= 7

      @playable_party_cards = ai_player.party_cards.in_hand.where('cost <= ?', ai_player.cost_current)
      @playable_party_cards.any?
    end

    def ai_play_a_party_card
      sleep 1
      analyzed_card = @playable_party_cards.first # temporary just grab one
      max_position = ai_player.party_cards.in_battlefield&.pluck(:position)&.max || 1
      chosen_position = rand(0..max_position)
      analyzed_card.chosen_position = chosen_position
      play_card(analyzed_card)
      @ai_has_playable_party_cards = ai_has_playable_party_cards?
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
