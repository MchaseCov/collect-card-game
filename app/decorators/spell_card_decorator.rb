# For use in the party_card_gamestates/ full_card and in_battle partials to dynamically change the data of the parent
class SpellCardDecorator
  def initialize(card)
    @card = card
  end

  def data_for_hand
    data = { # 'drag-spell-play-target' => 'playableCard',
      'gameplay-drag-target' => 'takesPlayerInput',
      'id' => @card.id,
      'cost' => @card.cost,
      'resource' => 'Resource',
      'action' => 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd'
    }
    if @card.cast_effect.player_choice
      data.tap do |hash|
        hash['cast-effect-select-target'] = 'choosableCast'
        hash['cast-effect'] = @card.cast_effect.id
      end
    end
    data
  end

  def data_fp_drawn_card
    { 'animations-target' => 'drawnCard' }
  end
end
