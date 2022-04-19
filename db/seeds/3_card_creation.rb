@neutral = Archetype.find_by(name: 'Neutral')
@ranger = Archetype.find_by(name: 'Ranger')
@wizard = Archetype.find_by(name: 'Wizard')
@barbarian = Archetype.find_by(name: 'Barbarian')
@token = Archetype.find_by(name: 'Token')
@neutral_party_cards = [
  { name: 'Gnome Serf', cost: 1, attack: 2, health: 1 }, # Battlecry: draw 1 card
  { name: 'Archer in Training', cost: 1, attack: 1, health: 1 }, # Battlecry: do 1 damage
  { name: 'Baby Alligator', tribe: 'Beast', cost: 1, attack: 1, health: 1 }, # Battlecry: Can immediately attack
  { name: 'Novice Summoner', cost: 2, attack: 1, health: 2 }, # Battlecry: Summon a 1/1 soldier
  { name: 'Distracting Bard', cost: 2, attack: 2, health: 2 }, # Taunt
  { name: 'Rescue Party', cost: 2, attack: 3, health: 2 }, # Battlecry: Return a party member from the battlefield back to your hand
  { name: 'Zealot of the Light', cost: 3, attack: 3, health: 3 }, # Deathrattle: Give a random friendly party member +2 health
  { name: 'Inexperienced Hunter', cost: 3, attack: 1, health: 1 }, # Deathrattle: Summon a 4/5 Bear
  { name: 'Eager Pickpocket', cost: 3, attack: 2, health: 3 }, # Battlecry: Gain a gold coin this turn
  { name: 'City Guard', cost: 4, attack: 4, health: 5 },
  { name: 'Faithful Priestess', cost: 4, attack: 3, health: 3 }, # Battlecry: Remove an enemy's status effects
  { name: 'Illusion Master', cost: 5, attack: 1, health: 1 }, # Battlecry: Choose a party member, summon a copy of it.
  { name: 'Cavalry Leader', cost: 5, attack: 2, health: 3 },  # Battlecry: Summon a 4/4 Knight
  { name: 'Highlands Hyena', tribe: 'Beast', cost: 5, attack: 2, health: 2 }, # Battlecry: Kill a random enemy party member with 3 or less health
  { name: 'Defensive Shieldmaster', cost: 5, attack: 5, health: 5 }, # Taunt
  { name: 'Halfling Ritualist', cost: 6, attack: 3, health: 3 }, # Deathrattle: Take control of a random enemy party member
  { name: 'Backstabber', cost: 6, attack: 7, health: 7 }, # Battlecry: You take 3 damage
  { name: 'Guild Leader', cost: 7, attack: 5, health: 5 } # While on board: Your other party minions have +1/+1
]

@ranger_party_cards = [
  { name: 'Stable Master', cost: 1, attack: 2, health: 1 }, # While on board: Your beasts have +1 attack
  { name: 'Loyal Wolf', tribe: 'Beast', cost: 2, attack: 2, health: 3 },
  { name: 'Beast Tamer', cost: 3, attack: 3, health: 2 }, # Battlecry: Give a friendly beast +2 health
  { name: 'Charging Hound', cost: 4, attack: 3, health: 3 }, # Battlecry: Can immediately attack
  { name: 'Protective Lioness', cost: 5, attack: 5, health: 5, tribe: 'Beast' } # Deathrattle: Summon two 2/2 lion cubs.
]

@wizard_party_cards = [
  { name: 'Observant Student', cost: 1, attack: 1, health: 2 }, # When you cast a spell: gain +1 attack
  { name: 'Conjured Fey', cost: 2, attack: 3, health: 2 },
  { name: 'Assistant Sorcerer', cost: 3, attack: 3, health: 2 }, # Battlecry: Reduce the cost of a spell in your hand by 1
  { name: 'Novice Caster', cost: 4, attack: 4, health: 5 }, # Battlecry: Deal 4 damage to a random enemy party minion
  { name: 'Mana Feeder', tribe: 'Beast', cost: 5, attack: 5, health: 6 } # When you cast a spell: gain +2/+1
]

@barbarian_party_cards = [
  { name: 'Bloodthirsty Raider', cost: 1, attack: 1, health: 3 }, # When damaged: gain 2 attack
  { name: 'Arms Dealer', cost: 2, attack: 3, health: 2 }, # Battlecry: give a party minion in your hand +1/+1
  { name: 'Glory Chaser', cost: 3, attack: 4, health: 4 }, # Start of turn: Attack a random enemy
  { name: 'Restless Combatant', cost: 4, attack: 4, health: 3 }, # Deathrattle: Summon a 4/1 Dangered combatant
  { name: 'Protective Goon', cost: 5, attack: 5, health: 5 } # If your hero has 15 or less health, summon a copy of this
]

@party_card_archetype_pairs = [
  { card_set: @neutral_party_cards, archetype: @neutral },
  { card_set: @ranger_party_cards, archetype: @ranger },
  { card_set: @wizard_party_cards, archetype: @wizard },
  { card_set: @barbarian_party_cards, archetype: @barbarian }
]
@party_card_archetype_pairs.each do |pair|
  pair[:card_set].each do |card|
    card_constant = CardConstant.create(name: card[:name], tribe: card[:tribe], archetype: pair[:archetype])
    card_constant = CardConstant.find_by(name: card[:name]) if card_constant.errors[:name] == ['has already been taken']
    CardReference.create(cost: card[:cost], attack: card[:attack], health: card[:health],
                         card_type: 'PartyCard', card_constant: card_constant)
  end

  @token_party_cards = [
    { name: 'Summoned Reinforcement', cost: 1, attack: 1, health: 1, summoner: CardConstant.find_by(name: 'Novice Summoner') }, # Neutral
    { name: 'Cavalry Knight', cost: 4, attack: 4, health: 4, summoner: CardConstant.find_by(name: 'Cavalry Leader') }, # Neutral
    { name: 'Hangry Bear', cost: 4, attack: 4, health: 5, summoner: CardConstant.find_by(name: 'Inexperienced Hunter'), tribe: 'Beast' }, # Neutral
    { name: 'Lion Cub', cost: 2, attack: 2, health: 2, summoner: CardConstant.find_by(name: 'Protective Lioness'), tribe: 'Beast' } # Ranger

  ]

  @token_party_cards.each do |card|
    card_constant = CardConstant.create(name: card[:name], tribe: card[:tribe], archetype: @token,
                                        summoner: card[:summoner])
    CardReference.create(cost: card[:cost], attack: card[:attack], health: card[:health],
                         card_type: 'PartyCard', card_constant: card_constant)
  end
end
