PartyCardParent.create(
  [
    {
      name: 'Gnome Serf',
      cost_default: 1,
      attack_default: 2,
      health_default: 1,
      tribe: 'Humanoid',
      archetype: Archetype.find_by(name: 'Neutral'),
      body: ''
    },
    {
      name: 'Loyal Wolf',
      cost_default: 2,
      attack_default: 2,
      health_default: 3,
      tribe: 'Beast',
      archetype: Archetype.find_by(name: 'Ranger'),
      body: ''
    },
    {
      name: 'Conjured Fey',
      cost_default: 2,
      attack_default: 3,
      health_default: 2,
      tribe: '',
      archetype: Archetype.find_by(name: 'Wizard'),
      body: ''
    },
    {
      name: 'Beast Tamer',
      cost_default: 3,
      attack_default: 3,
      health_default: 2,
      tribe: 'Humanoid',
      archetype: Archetype.find_by(name: 'Ranger'),
      body: 'Give a friendly beast +2 health'
    }
  ]
)
