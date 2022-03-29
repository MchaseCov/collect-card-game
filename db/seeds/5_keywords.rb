# If player_chice false, target is chain required to self-evaluate appropriate target
# If true, target is in format [target_type, attribute, attribute_value]
Keyword.create(
  [
    {
      # SPELL CARD: FLAME NOVA : DEAL 1 DAMAGE TO ALL ENEMY PARTY MEMBERS IN PLAY
      type: 'Cast',
      player_choice: false,
      target: %w[opposing_player_of_card party_cards in_battle],
      action: 'take_damage',
      modifier: 2,
      card_constant: CardConstant.find_by(name: 'Flame Nova'),
      body_text: 'Deal 2 damage to all enemy party members in battle.'
    }
  ]
)
battlecries = [
  {
    player_choice: true,
    target: %w[player_of_card party_cards in_battle beast_tribe],
    card_constant: CardConstant.find_by(name: 'Beast Tamer'),
    body_text: 'Give +2 health to a friendly Beast in battle.',
    associated_buff: Buff.find_by(name: 'Bestial Strength')
  },
  {
    target: ['player_of_card'],
    action: 'draw_cards',
    modifier: 1,
    card_constant: CardConstant.find_by(name: 'Gnome Serf'),
    body_text: 'Draw a card.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Archer in Training'),
    target: %w[opposing_player_of_card party_cards in_battle],
    player_choice: true,
    action: 'take_damage',
    modifier: 1,
    body_text: 'Deal 1 damage to an enemy in battle.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Baby Alligator'),
    target: %w[invoking_card],
    action: 'status_attacking',
    modifier: nil,
    body_text: 'Can instantly attack.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Novice Summoner'),
    target: %w[invoking_card],
    action: 'summon_token',
    modifier: nil,
    body_text: 'Summon a 1/1 Reinforcement'
  },
  {
    card_constant: CardConstant.find_by(name: 'Rescue Party'),
    target: %w[player_of_card party_cards in_battle],
    player_choice: true,
    action: 'return_to_hand',
    body_text: 'Return a friendly Party Card from the Battlefield to your Hand.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Eager Pickpocket'),
    target: %w[player_of_card],
    action: 'increment_cost_current',
    modifier: 1,
    body_text: 'Gain 1 gold coin this turn.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Faithful Priestess'),
    target: %w[opposing_player_of_card party_cards in_battle],
    player_choice: true,
    action: 'silence',
    body_text: 'Silence an enemy Party Card, removing ALL of its status effects.'
  }
]
battlecries.each do |battlecry|
  bc = Battlecry.create(
    card_constant: battlecry[:card_constant],
    target: battlecry[:target],
    player_choice: battlecry[:player_choice],
    action: battlecry[:action],
    body_text: battlecry[:body_text]
  )
  bc.buffs << battlecry[:associated_buff] if battlecry[:associated_buff].present?
end

taunt_text = 'Must be attacked first'
taunt_buff = Buff.find_by(name: 'Taunt')
taunts = [
  {
    card_constant: CardConstant.find_by(name: 'Distracting Bard')
  }
]
taunts.each do |taunt|
  t = Taunt.create(card_constant: taunt[:card_constant], target: %w[invoking_card], body_text: taunt_text)
  t.buffs << taunt_buff
end
