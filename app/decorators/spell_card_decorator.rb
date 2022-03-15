# For use in the party_card_gamestates/ full_card and in_battle partials to dynamically change the data of the parent
class SpellCardDecorator
  def initialize(card)
    @card = card
  end

  def data_for_hand
    { 'drag-party-play-target' => 'playableCard',
      'id' => @card.id,
      'cost' => @card.cost,
      'action' => 'dragstart->drag-party-play#dragStart dragend->drag-party-play#dragEnd' }
  end

  def data_fp_drawn_card
    { 'animations-target' => 'drawnCard' }
  end
end
