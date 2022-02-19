# Keywords with type "Battlecry" to trigger upon card play
class Battlecry < Keyword
  def trigger(invoking_card, target = '')
    return unless invoking_card.status == 'battle'

    super
  end
end
