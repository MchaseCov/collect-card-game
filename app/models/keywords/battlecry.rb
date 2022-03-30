# Keywords with type "Battlecry" to trigger upon card play
class Battlecry < Keyword
  def trigger(invoking_card, target_input)
    return unless invoking_card.location == 'battle'
    return if player_choice && target_input.blank?

    super
  end
end
