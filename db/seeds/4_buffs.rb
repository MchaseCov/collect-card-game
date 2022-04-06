Buff.create(
  [
    {
      name: 'Bestial Strength',
      target_method: 'increase_health_cap',
      removal_method: 'decrease_health_cap',
      modifier: 2
    },
    {
      name: 'Taunt',
      target_method: 'begin_taunt',
      removal_method: 'end_taunt'
    },
    {
      name: 'Guild Membership',
      target_method: 'increase_stats',
      removal_method: 'decrease_stats',
      modifier: 1
    },
    {
      name: "Light's Grace",
      target_method: 'increase_health_cap',
      removal_method: 'decrease_health_cap',
      modifier: 2
    },
    {
      name: 'Stabled Might',
      target_method: 'increase_stats',
      removal_method: 'decrease_stats',
      modifier: 1
    },
    {
      name: 'Wizard Wisdom',
      target_method: 'increment_attack',
      removal_method: 'decrement_attack',
      modifier: 1
    },
    {
      name: 'Mana Engorged',
      target_method: 'increase_stats',
      removal_method: 'decrease_stats',
      modifier: 2
    }
  ]
)
