# For use in the party_card_gamestates/ full_card and in_battle partials to dynamically change the data of the parent
class PartyCardGamestateDecorator
  def initialize(card)
    @card = card
  end

  def data_for_hand
    data = {
      'id' => @card.id,
      'resource' => 'Cost',
      'cost' => @card.cost,
      'gameplay-drag-target' => 'playsToBoard',
      'action' => 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd',
      'gameplay-drag-type-param' => 'party',
      'gameplay-drag-action-param' => 'play_card'
    }

    return data unless @card.battlecry.present? && @card.battlecry.player_choice

    data.tap do |hash|
      hash['gameplay-drag-target-type-param'] = 'battlecry'
      hash['battlecry'] = @card.battlecry.id
      hash['gameplay-drag-target'] += ' takesPlayerInput'
    end
    data
  end

  def data_for_last_played
    { 'animations-target' => 'lastPlayed', 'animation-of' => @card.id }
  end

  def data_friendly_card_board_battle
    {
      'style-cards-target' => 'boardMinion',
      'gameplay-drag-target' => 'recievesPlayerInput friendlyActor',
      'id' => @card.id,
      'status' => @card.status,
      'health-current' => @card.health,
      'health-cap' => @card.health_cap,
      'action' => 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd'
    }
  end

  def data_opposing_card_board_battle
    {
      'style-cards-target' => 'boardMinion',
      'gameplay-drag-target' => 'recievesPlayerInput enemyActor',
      'id' => @card.id,
      'status' => @card.status,
      'health-current' => @card.health,
      'health-cap' => @card.health_cap,
      'type' => 'party',
      'action' => 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd'
    }
  end

  def data_fp_drawn_card
    { 'animations-target' => 'drawnCard' }
  end

  def board_space_data(first_person)
    data = { 'board-id' => @card.position }

    return data unless first_person

    data.tap do |hash|
      hash['gameplay-drag-target'] = 'recievesPlayToBoard'
      hash['gameplay-drag-board-target-param'] = @card.position
      hash['action'] =
        'drop->gameplay-drag#boardspaceDrop dragenter->gameplay-drag#boardspaceDragEnter dragover->gameplay-drag#dragOver'
    end
    data
  end
end
