class Taunt < Keyword
  def trigger(card)
    card.buffs << buff
  end
end
