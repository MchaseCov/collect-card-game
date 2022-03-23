module SingleplayerAi
  def initialize_ai
    ai_user = User.find_by(email: 'ai@bot.com')
    ai_user.account_decks.includes(:archetype, :race).first
  end

  def ai_mulligan
    ai_player.update(status: 'default')
    return if ai_player.cards.in_mulligan.sum(:cost) < 9

    ai_player.draw_mulligan_cards
  end

  def begin_ai_turn
    @attacking_cards = ai_player.party_cards.in_battle.where(status: 'attacking')
    @ai_can_play_party_card = ai_can_play_party_card
    sleep 2
    conduct_ai_attack while @attacking_cards.any?
    play_ai_party_card while @ai_can_play_party_card
    end_turn
  end

  private

  def ai_can_play_party_card
    @playable_party_cards = ai_player.party_cards.in_hand.where('cost <= ?', player_two.cost_current)
    (@playable_party_cards.any? && ai_player.party_cards.in_battle.size < 7)
  end

  def conduct_ai_attack
    attacking_card = @attacking_cards.sample
    enemy_to_attack = human_player.party_cards.in_battle.sample || human_player
    conduct_attack(attacking_card, enemy_to_attack)
    @attacking_cards -= [attacking_card]
    sleep 1
  end

  def play_ai_party_card
    card_to_play = @playable_party_cards.sample
    max_position = ai_player.party_cards.in_battle&.pluck(:position)&.max || 0
    chosen_position = rand(0..max_position)
    play_party(card_to_play, chosen_position)
    @ai_can_play_party_card = ai_can_play_party_card
    sleep 1
  end
end
