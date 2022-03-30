# Keywords with type "Cast" to trigger upon spell card cast
class Cast < Keyword
  def trigger(invoking_card, target_input)
    return unless invoking_card.status == 'spent'
    return if player_choice && target_input.blank?

    super
  end
end
