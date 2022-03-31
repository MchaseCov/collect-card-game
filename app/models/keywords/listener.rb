class Listener < Keyword
  validates_presence_of :listening_condition

  def trigger(invoking_card)
    @invoking_card = invoking_card
    active_listener = @invoking_card.build_active_listener_effect(listener: self)
    active_listener.cards << set_final_target
  end

  def activate_effect(listening_card)
    @targets = listening_card
    method(action).call
  end
end
