class AiBoardClear < AiDecisionDatum
  def evaluate_weight_of_card(game)
    targets_affected = evaluate_targets(game)
    damage_to_each = card_weight['damage']
    evaluate_damage_done(targets_affected, damage_to_each)
  end

  def evaluate_damage_done(targets_affected, damage_to_each)
    enemies_killed = 0
    overkill_damage = 0
    targets_affected.each do |target|
      next unless target.health <= damage_to_each

      overkill_damage += (damage_to_each - target.health)
      enemies_killed += 1
    end
    { kills: enemies_killed, overkill: overkill_damage, constant: card_constant }
  end
end
