# Actions from Keywords to apply to targets. Allows for advanced possibilities and creative keywords as opposed to calling
# existing methods on cards themselves
module GenericKeywordActions
  private

  # Inflict damage to a card in battle or player
  def take_damage
    Array(@targets).each { |t| t.take_damage(modifier) }
  end

  # Apply buffs to a card. See "Auras" for applying buffs to a player.
  def apply_buffs
    Array(@targets).each { |t| t.buffs << buffs }
  end

  # Player draws cards equal to the amount of modifier
  def draw_cards
    Array(@targets).each { |t| t.draw_cards(modifier) }
  end

  # Allows a party card to attack instantly without waiting a turn.
  def instantly_attack
    Array(@targets).each(&:status_attack_ready!)
  end

  # A card summons x amount of its associated token
  def summon_token
    Array(@targets).each { |t| t.summon_token(modifier) }
  end

  # Summon a copy of the target card.
  def summon_copy
    Array(@targets).each { |t| t.summon_copy(modifier) }
  end

  # A card is returned to hand
  def return_to_hand
    Array(@targets).each(&:return_to_hand)
  end

  # Increases the amount of gold a player has on a single turn.
  def increase_current_gold
    Array(@targets).each { |t| t.increment_cost_current(modifier) }
  end

  # Removes all buffs from a card.
  def silence
    Array(@targets).each(&:silence)
  end
end
