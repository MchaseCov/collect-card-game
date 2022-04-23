Archetype.create(
  [
    {
      name: 'Barbarian',
      description: 'A fierce warrior with a rage for battle',
      resource_type: 'energy',
      color: 3
    },
    {
      name: 'Wizard',
      description: 'A scholar in the arcane arts',
      resource_type: 'mana',
      color: 1
    },
    {
      name: 'Ranger',
      description: 'A warrior of the wilds',
      resource_type: 'hybrid',
      color: 2
    },
    {
      name: 'Neutral',
      description: 'Neutral cards are usable by all Archetypes!',
      resource_type: 'hybrid',
      color: 0
    },
    {
      name: 'Token',
      description: 'Tokens are cards that are not added to decks, but are summoned in game!',
      resource_type: 'hybrid',
      color: 0
    }
  ]
)
