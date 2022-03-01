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
      party_card_parent_id: PartyCardParent.find_by(name: 'Gnome Serf').id,
      body_text: 'Draw a card.'
    },
    {
      # BATTLECRY: BEAST TAMER : GIVE BEAST 1 HEALTH
      type: 'Battlecry',
      player_choice: true,
      target: %w[player_of_card cards in_battle beast_tribe],
      action: 'increase_health_cap',
      modifier: 2,
      party_card_parent_id: PartyCardParent.find_by(name: 'Beast Tamer').id,
      body_text: 'Give +2 health to a friendly Beast in battle.'
    }
  ]
)
