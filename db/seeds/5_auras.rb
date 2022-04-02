auras = [
  {
    card_constant: CardConstant.find_by(name: 'Guild Leader'),
    target: %w[party_cards in_battlefield],
    associated_buff: Buff.find_by(name: 'Guild Membership'),
    modifier: 1,
    body_text: 'While this is in play, your Party Cards in battle have +1/+1'
  },
  {
    card_constant: CardConstant.find_by(name: 'Stable Master'),
    target: %w[player_of_card party_cards in_battlefield beast_tribe],
    associated_buff: Buff.find_by(name: 'Stabled Might'),
    modifier: 1,
    body_text: 'While this is in play, your Beasts in battle have +1/+1'
  }
]
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
