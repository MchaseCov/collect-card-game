CardReference.create(
  [
    {
      cost: 1,
      attack: 2,
      health: 1,
      card_type: 'PartyCard',
      card_constant: CardConstant.find_by(name: 'Gnome Serf')
    },
    {
      cost: 2,
      attack: 2,
      health: 3,
      card_type: 'PartyCard',
      card_constant: CardConstant.find_by(name: 'Loyal Wolf')
    },
    {
      cost: 2,
      attack: 3,
      health: 2,
      card_type: 'PartyCard',
      card_constant: CardConstant.find_by(name: 'Conjured Fey')
    },
    {
      cost: 3,
      attack: 3,
      health: 2,
      card_type: 'PartyCard',
      card_constant: CardConstant.find_by(name: 'Beast Tamer')
    },
    {
      cost: 2,
      card_type: 'SpellCard',
      card_constant: CardConstant.find_by(name: 'Flame Nova')
    }
  ]
)
