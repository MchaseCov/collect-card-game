# Keyword for effects to take place while the aura card is on board
class Aura < Keyword
  def trigger(invoking_card)
    @invoking_card = invoking_card
    player_of_card.auras << buff
  end

  def stop_aura(invoking_card)
    @invoking_card = invoking_card
    player_of_card.auras.destroy(buff)
  end
end
