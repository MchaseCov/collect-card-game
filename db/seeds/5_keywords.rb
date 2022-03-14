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
    }
  ]
)
