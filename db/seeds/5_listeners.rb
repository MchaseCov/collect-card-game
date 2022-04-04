listeners = [
  {
    card_constant: CardConstant.find_by(name: 'Observant Student'),
    target: %w[player_of_card spell_cards],
    listening_condition: 'spell_card_played',
    action: 'apply_buffs',
    associated_buff: Buff.find_by(name: 'Wizard Wisdom'),
    modifier: 1,
    body_text: 'Whenever you cast a spell, gain +1 attack.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Mana Feeder'),
    target: %w[player_of_card spell_cards],
    listening_condition: 'spell_card_played',
    action: 'apply_buffs',
    associated_buff: Buff.find_by(name: 'Mana Engorged'),
    modifier: 1,
    body_text: 'Whenever you cast a spell, gain +2/+2.'
  }
]
listeners.each do |listener|
  ls = Listener.create(
    card_constant: listener[:card_constant],
    target: listener[:target],
    listening_condition: listener[:listening_condition],
    action: listener[:action],
    modifier: listener[:modifier],
    body_text: listener[:body_text],
    player_choice: false
  )
  ls.buffs << listener[:associated_buff] if listener[:associated_buff].present?
end
