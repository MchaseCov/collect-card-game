abilities = [
  {
    action: 'apply_buffs',
    modifier: nil,
    body_text: 'Give +2 health to a friendly Beast in battle.',
    random: 0,
    associated_buff: Buff.find_by(name: 'Bestial Strength'),
  }
]

abilities.each do |ability|
  ab = Ability.create(
    action: ability[:action],
    modifier: ability[:modifier],
    body_text: ability[:body_text],
    random: ability[:random]
  )
  ab.buffs << ability[:associated_buff] if ability[:associated_buff].present?
end
