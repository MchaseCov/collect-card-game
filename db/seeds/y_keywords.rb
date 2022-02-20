# If player_chice false, target is chain required to self-evaluate appropriate target
# If true, target is in format [target_type, attribute, attribute_value]
Keyword.create(
  [
    {
      # BATTLECRY: GNOME SERF : DRAW 1 CARD
      type: 'Battlecry',
      target: ['player'],
      action: 'draw_cards',
      modifier: 1,
      party_card_parent_id: PartyCardParent.find_by(name: 'Gnome Serf').id
    },
    {
      # BATTLECRY: BEAST TAMER : GIVE BEAST 1 HEALTH
      type: 'Battlecry',
      player_choice: true,
      target: %w[friendly_battle tribe beast],
      action: 'increase_health_cap',
      modifier: 2,
      party_card_parent_id: PartyCardParent.find_by(name: 'Beast Tamer').id
    }
  ]
)
