AbilityTrigger.create(
  [
    {
      ability: Ability.find_by(body_text: 'Give +2 health to a friendly Beast in battle.'),
      trigger: 'instant',
      target_scope: 'specified',
      alignment: 'friendly_team',
      target_type: 'party',
      additional_scoping: 0,
      card_constant: CardConstant.find_by(name: 'Beast Tamer')
    }
  ]
)
