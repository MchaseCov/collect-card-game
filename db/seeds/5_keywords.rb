# If player_chice false, target is chain required to self-evaluate appropriate target
# If true, target is in format [target_type, attribute, attribute_value]
Keyword.create(
  [
    {
      # BATTLECRY: GNOME SERF : DRAW 1 CARD
      type: 'Battlecry',
      target: ['player_of_card'],
      action: 'draw_cards',
      modifier: 1,
      card_constant: CardConstant.find_by(name: 'Gnome Serf'),
      body_text: 'Draw a card.'
    },
    {
      # BATTLECRY: BEAST TAMER : GIVE BEAST 1 HEALTH
      type: 'Battlecry',
      player_choice: true,
      target: %w[player_of_card party_cards in_battle beast_tribe],
      card_constant: CardConstant.find_by(name: 'Beast Tamer'),
      body_text: 'Give +2 health to a friendly Beast in battle.'
    },
    {
      # SPELL CARD: FLAME NOVA : DEAL 1 DAMAGE TO ALL ENEMY PARTY MEMBERS IN PLAY
      type: 'Cast',
      player_choice: false,
      target: %w[opposing_player_of_card party_cards in_battle],
      action: 'take_damage',
      modifier: 2,
      card_constant: CardConstant.find_by(name: 'Flame Nova'),
      body_text: 'Deal 2 damage to all enemy party members in battle.'
    }
  ]
)
