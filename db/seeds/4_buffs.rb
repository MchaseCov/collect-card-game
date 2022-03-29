Buff.create(
  [
    {
      name: 'Bestial Strength',
      target_method: 'increase_health_cap',
      removal_method: 'decrease_health_cap',
      modifier: 2
    },
    {
      name: 'Taunt'
    },
    {
      name: 'Guild Membership',
      target_method: 'increase_stats',
      removal_method: 'decrease_stats',
      modifier: 1
    }
  ]
)
