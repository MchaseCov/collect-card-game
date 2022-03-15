@neutral = Archetype.find_by(name: 'Neutral')
@ranger = Archetype.find_by(name: 'Ranger')
@wizard = Archetype.find_by(name: 'Wizard')
CardConstant.create(
  [
    {
      name: 'Gnome Serf',
      tribe: 'Humanoid',
      archetype: @neutral
    },
    {
      name: 'Loyal Wolf',
      tribe: 'Beast',
      archetype: @ranger
    },
    {
      name: 'Conjured Fey',
      tribe: '',
      archetype: @wizard
    },
    {
      name: 'Beast Tamer',
      tribe: 'Humanoid',
      archetype: @ranger
    },
    {
      name: 'Flame Nova',
      tribe: 'Fire',
      archetype: @wizard
    }
  ]
)
