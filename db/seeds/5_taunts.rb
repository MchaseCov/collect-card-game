taunt_text = 'Must be attacked first'
taunt_buff = Buff.find_by(name: 'Taunt')
cards_with_taunt = [CardConstant.find_by(name: 'Distracting Bard'),
                    CardConstant.find_by(name: 'Defensive Shieldmaster')]
cards_with_taunt.each do |card|
  t = Taunt.create(card_constant: card, target: %w[invoking_card], body_text: taunt_text)
  t.buffs << taunt_buff
end
