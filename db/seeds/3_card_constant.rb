@wizard = Archetype.find_by(name: 'Wizard')
CardConstant.create(
  [

    {
      name: 'Flame Nova',
      tribe: 'Fire',
      archetype: @wizard
    }
  ]
)
