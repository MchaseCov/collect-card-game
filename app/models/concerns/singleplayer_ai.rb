# This file is no longer for use, but rather for reference
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
    @attacking_cards = ai_player.party_cards.in_battlefield.where(status: 'attacking')
    @ai_can_play_party_card = ai_can_play_party_card
    sleep 2
    if human_player.party_cards.in_battlefield.size > 0 && ai_player.spell_cards.in_hand.size > 0
      bc_score = analyze_board_clear_cards
    end
    if bc_score.present? && bc_score[:score].positive?
      play_spell(ai_player.spell_cards.in_hand.find_by(card_constant: bc_score[:card]))
      sleep 1
    end
    conduct_ai_attack while @attacking_cards.any?
    ai_play_party_card while @ai_can_play_party_card
    end_turn
  end

  private

  def analyze_board_clear_cards
    card_analysis_set = []
    current_highest_kills = 0
    board_clear_cards.each do |card|
      card_analysis = card.ai_decision_datum.evaluate_weight_of_card(self)
      next if card_analysis[:kills] < current_highest_kills

      if card_analysis[:kills] > current_highest_kills
        card_analysis_set.clear
        current_highest_kills = card_analysis[:kills]
      end
      card_analysis_set << card_analysis
    end
    puts 'analysis set'
    puts card_analysis_set
    final_card = card_analysis_set.min_by { |ca| ca[:overkill] }
    puts 'Final Card'
    puts final_card
    { card: final_card[:constant],
      score: ((final_card[:kills].to_f / human_player.party_cards.in_battlefield.size) * 100).to_i }
  end

  def ai_can_play_party_card
    @playable_party_cards = ai_player.party_cards.in_hand.includes(card_constant: :ai_decision_datum).where(
      'cost <= ?', player_two.cost_current
    )

    (@playable_party_cards.any? && ai_player.party_cards.in_battlefield.size < 7)
  end

  def conduct_ai_attack
    attacking_card = @attacking_cards.sample
    enemy_to_attack = human_player.party_cards.in_battlefield.sample || human_player
    conduct_attack(attacking_card, enemy_to_attack)
    @attacking_cards -= [attacking_card]
    sleep 1
  end

  def ai_play_party_card
    analyzed_card = analyze_party_cards
    puts analyzed_card
    max_position = ai_player.party_cards.in_battlefield&.pluck(:position)&.max || 0
    chosen_position = rand(0..max_position)
    play_party(analyzed_card[:card], chosen_position)
    @ai_can_play_party_card = ai_can_play_party_card
    sleep 1
  end

  def play_ai_party_card
    card_to_play = @playable_party_cards.sample
    max_position = ai_player.party_cards.in_battlefield&.pluck(:position)&.max || 0
    chosen_position = rand(0..max_position)
    play_party(card_to_play, chosen_position)
    @ai_can_play_party_card = ai_can_play_party_card
    sleep 1
  end

  def board_clear_cards
    ai_player.spell_cards
             .in_hand
             .includes(card_constant: :ai_decision_datum)
             .where('cost <= ?', ai_player.resource_current)
             .map(&:card_constant)
             .uniq
  end

  def analyze_party_cards
    best_card = { card: nil, score: 0 }
    @playable_party_cards.each do |card|
      ai_decision_datum = card.card_constant.ai_decision_datum
      score = (card.health + card.attack) * 5
      score += ai_decision_datum.evaluate_weight_of_card(self) if ai_decision_datum.present?
      best_card = { card: card, score: score } if score > best_card[:score]
    end
    best_card
  end
end
