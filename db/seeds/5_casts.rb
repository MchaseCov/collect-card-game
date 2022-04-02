# If player_chice false, target is chain required to self-evaluate appropriate target
# If true, target is in format [target_type, attribute, attribute_value]
Cast.create(
  [
    {
      # SPELL CARD: FLAME NOVA : DEAL 1 DAMAGE TO ALL ENEMY PARTY MEMBERS IN PLAY
      player_choice: false,
      target: %w[opposing_player_of_card party_cards in_battlefield],
      action: 'take_damage',
      modifier: 2,
      card_constant: CardConstant.find_by(name: 'Flame Nova'),
      body_text: 'Deal 2 damage to all enemy party members in battle.'
    }
  ]
)
