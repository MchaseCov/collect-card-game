Race.create(
  [
    {
      name: 'Dwarf',
      description:
      "Dwarves are skilled warriors with an affinity for stone and metal work.
      Racial bonuses:
      Hearty Nature: Start your games with 5 extra life points!",
      health_modifier: 5,
      cost_modifier: 0,
      resource_modifier: 0
    },
    {
      name: 'Human',
      description:
      "Humans are the most adaptable and ambitious among the common races.
      Racial bonuses:
      Polyglot: Your ability to communicate with the wide range of races nets you 1 extra starting coin",
      health_modifier: 0,
      cost_modifier: 1,
      resource_modifier: 0
    },
    {
      name: 'Elf',
      description:
      "Elves are a magical race who live their long lives hidden among the trees.
      Racial bonuses:
      Agile: You begin with 2 extra resource points, but your maximum life is reduced by 3 life points.",
      health_modifier: -3,
      cost_modifier: 0,
      resource_modifier: 2
    }
  ]
)
