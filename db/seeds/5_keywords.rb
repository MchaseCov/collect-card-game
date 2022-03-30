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
    target: %w[opposing_player_of_card party_cards in_battle],
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
    target: %w[player_of_card party_cards in_battle],
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
    target: %w[opposing_player_of_card party_cards in_battle],
    player_choice: true,
    action: 'silence',
    body_text: 'Silence an enemy Party Card, removing ALL of its status effects.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Illusion Master'),
    target: %w[player_of_card party_cards in_battle],
    action: 'summon_copy',
    player_choice: true,
    modifier: 1,
    body_text: 'Choose a friendly Party Card in battle. Summon a copy of it.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Highlands Hyena'),
    target: %w[game_of_card cards in_battle],
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

taunt_text = 'Must be attacked first'
taunt_buff = Buff.find_by(name: 'Taunt')
cards_with_taunt = [CardConstant.find_by(name: 'Distracting Bard'),
                    CardConstant.find_by(name: 'Defensive Shieldmaster')]
cards_with_taunt.each do |card|
  t = Taunt.create(card_constant: card, target: %w[invoking_card], body_text: taunt_text)
  t.buffs << taunt_buff
end

auras = [{
  card_constant: CardConstant.find_by(name: 'Guild Leader'),
  target: %w[party_cards in_battle],
  associated_buff: Buff.find_by(name: 'Guild Membership'),
  modifier: 1,
  body_text: 'While this is in play, your Party Cards in battle have +1/+1'
}]
auras.each do |aura|
  au = Aura.create(
    card_constant: aura[:card_constant],
    target: aura[:target],
    player_choice: false,
    modifier: aura[:modifier],
    body_text: aura[:body_text]
  )
  au.buffs << aura[:associated_buff] if aura[:associated_buff].present?
end
