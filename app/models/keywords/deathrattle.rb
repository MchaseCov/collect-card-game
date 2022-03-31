# Keywords with type "Deathrattle" to trigger upon card death
class Deathrattle < Keyword
  def trigger(invoking_card)
    return unless invoking_card.status == 'dead'

    @invoking_card = invoking_card
    @targets = set_final_target
    method(action).call
  end
end
