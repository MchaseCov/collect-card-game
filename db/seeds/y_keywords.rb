Keyword.create(
  [
    {
      # BATTLECRY: GNOME SERF : DRAW 1 CARD
      type: 'Battlecry',
      target: ['player'],
      action: 'draw_cards',
      modifier: 1,
      party_card_parent_id: PartyCardParent.find_by(name: 'Gnome Serf').id
    }
  ]
)
