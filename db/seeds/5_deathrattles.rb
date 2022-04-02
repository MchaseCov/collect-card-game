deathrattles = [
  {
    card_constant: CardConstant.find_by(name: 'Zealot of the Light'),
    target: %w[player_of_card party_cards in_battlefield sample],
    action: 'apply_buffs',
    associated_buff: Buff.find_by(name: "Light's Grace"),
    modifier: 1,
    body_text: 'Give +2 health to a random friendly Party Card in battle.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Inexperienced Hunter'),
    target: %w[invoking_card],
    action: 'summon_token',
    modifier: 1,
    body_text: 'Summon a 4/5 bear.'
  },
  {
    card_constant: CardConstant.find_by(name: 'Protective Lioness'),
    target: %w[invoking_card],
    action: 'summon_token',
    modifier: 2,
    body_text: 'Summon two 2/2 lion cubs.'
  }
]
deathrattles.each do |deathrattle|
  dr = Deathrattle.create(
    card_constant: deathrattle[:card_constant],
    target: deathrattle[:target],
    player_choice: false,
    action: deathrattle[:action],
    modifier: deathrattle[:modifier],
    body_text: deathrattle[:body_text]
  )
  dr.buffs << deathrattle[:associated_buff] if deathrattle[:associated_buff].present?
end
