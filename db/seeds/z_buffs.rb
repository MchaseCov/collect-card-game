Buff.create(
  [
    {
      name: 'Bestial Strength',
      target_method: 'increase_health_cap',
      removal_method: 'decrease_health_cap',
      modifier: 2,
      keyword_id: PartyCardParent.find_by(name: 'Beast Tamer').battlecry.id
    }
  ]
)
