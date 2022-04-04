# Keyword for effects to take place while the aura card is on board
class Aura < Keyword
  attr_reader :targets

  def trigger(invoking_card)
    @invoking_card = invoking_card
    targets = set_final_target - [@invoking_card]
    player_of_card.auras << buff
    targets.each { |c| c.buffs << buff }
  end

  def stop_aura(invoking_card)
    @invoking_card = invoking_card
    player_of_card.auras.destroy(buff)
  end
end
