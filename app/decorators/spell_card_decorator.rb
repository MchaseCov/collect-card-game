# For use in the party_card_gamestates/ full_card and in_battle partials to dynamically change the data of the parent
class SpellCardDecorator
  def initialize(card)
    @card = card
  end

  def data_for_hand
    data = { # 'drag-spell-play-target' => 'playableCard',
      'id' => @card.id,
      'resource' => 'Resource',
      'cost' => @card.cost,
      'gameplay-drag-target' => 'spellCard',
      'action' => 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd',
      'gameplay-drag-type-param' => 'spell',
      'gameplay-drag-action-param' => 'play_card'
    }
    if @card.keywords.to_a.find { |k| k[:type] == 'Cast' }.player_choice
      data.tap do |hash|
        hash['gameplay-drag-target-type-param'] = 'cast'
        hash['cast'] = @card.cast_effect.id
        hash['gameplay-drag-target'] += ' takesPlayerInput'
      end
    end
    data
  end

  def data_for_last_played
    { 'animations-target' => 'lastPlayed', 'animation-of' => @card.id }
  end

  def data_fp_drawn_card
    { 'animations-target' => 'drawnCard' }
  end
end
