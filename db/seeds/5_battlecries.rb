battlecries = [
  {
    player_choice: true,
    target: %w[player_of_card party_cards in_battlefield beast_tribe],
    action: 'apply_buffs',
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
    target: %w[opposing_player_of_card party_cards in_battlefield],
    player_choice: true,
    action: 'take_damage',
    modifier: 1,
    body_text: 'Deal 1 damage to an enemy in battle.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Baby Alligator'),
    target: %w[invoking_card],
    action: 'instantly_attack',
    modifier: nil,
    body_text: 'Can instantly attack.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Novice Summoner'),
    target: %w[invoking_card],
    action: 'summon_token',
    modifier: 1,
    body_text: 'Summon a 1/1 Reinforcement'
  },
  {
    card_constant: CardConstant.find_by(name: 'Rescue Party'),
    target: %w[player_of_card party_cards in_battlefield],
    player_choice: true,
    action: 'return_to_hand',
    body_text: 'Return a friendly Party Card from the Battlefield to your Hand.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Eager Pickpocket'),
    target: %w[player_of_card],
    action: 'increase_current_gold',
    modifier: 1,
    body_text: 'Gain 1 gold coin this turn.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Faithful Priestess'),
    target: %w[opposing_player_of_card party_cards in_battlefield],
    player_choice: true,
    action: 'silence',
    body_text: 'Silence an enemy Party Card, removing ALL of its status effects.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Illusion Master'),
    target: %w[player_of_card party_cards in_battlefield],
    action: 'summon_copy',
    player_choice: true,
    modifier: 1,
    body_text: 'Choose a friendly Party Card in battle. Summon a copy of it.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Highlands Hyena'),
    target: %w[game_of_card cards in_battlefield],
    action: 'highlands_hyena',
    modifier: nil,
    body_text: 'Destroy ALL Party Cards in battle with two or less health'
  },
  {
    card_constant: CardConstant.find_by(name: 'Cavalry Leader'),
    target: %w[invoking_card],
    action: 'summon_token',
    modifier: 1,
    body_text: 'Summon a 4/4 Knight.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Backstabber'),
    target: %w[player_of_card],
    action: 'take_damage',
    modifier: 3,
    body_text: 'You take 3 damage when playing this card.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Charging Hound'),
    target: %w[invoking_card],
    action: 'instantly_attack',
    modifier: nil,
    body_text: 'Can instantly attack.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Assistant Sorcerer'),
    target: %w[player_of_card spell_cards in_hand sample],
    action: 'reduce_cost',
    modifier: 1,
    body_text: 'Reduce the cost of a Spell Card in your Hand by 1.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Novice Caster'),
    target: %w[opposing_player_of_card party_cards in_battlefield sample],
    action: 'take_damage',
    modifier: 4,
    body_text: 'Deal 4 damage to a random enemy Party Card in battle.'
  }
]
battlecries.each do |battlecry|
  bc = Battlecry.create(
    card_constant: battlecry[:card_constant],
    target: battlecry[:target],
    player_choice: battlecry[:player_choice] || false,
    action: battlecry[:action],
    modifier: battlecry[:modifier],
    body_text: battlecry[:body_text]
  )
  bc.buffs << battlecry[:associated_buff] if battlecry[:associated_buff].present?
end
