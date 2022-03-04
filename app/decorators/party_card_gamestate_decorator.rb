# For use in the party_card_gamestates/ full_card and in_battle partials to dynamically change the data of the parent
class PartyCardGamestateDecorator
  def initialize(card)
    @card = card
  end

  def data_for_hand
    data = { 'drag-party-play-target' => 'playableCard',
             'id' => @card.id,
             'cost' => @card.cost_current,
             'action' => 'dragstart->drag-party-play#dragStart dragend->drag-party-play#dragEnd' }
    return data unless @card.parent.battlecry.present? && @card.parent.battlecry.player_choice

    data.tap do |hash|
      hash['battlecry-select-target'] = 'choosableBattlecry'
      hash['battlecry'] = @card.battlecry.id
    end
    data
  end

  def data_for_last_played
    { 'animations-target' => 'lastPlayed', 'animation-of' => @card.id }
  end

  def data_friendly_card_board_battle
    {
      'drag-battle-target' => 'activeFriendlyActor',
      'drag-party-play-target' => 'friendlyCardInBattle',
      'style-cards-target' => 'boardMinion',
      'id' => @card.id,
      'status' => @card.status,
      'health-current' => @card.health_current,
      'health-cap' => @card.health_cap,
      'action' => 'dragstart->drag-battle#dragStart dragend->drag-battle#dragEnd'
    }
  end

  def data_opposing_card_board_battle
    {
      'drag-battle-target' => 'enemyActor',
      'battlecry-select-target' => 'enemyMinionActor',
      'style-cards-target' => 'boardMinion',
      'id' => @card.id,
      'status' => @card.status,
      'health-current' => @card.health_current,
      'health-cap' => @card.health_cap,
      'action' => 'drop->drag-battle#drop dragenter->drag-battle#dragEnter dragover->drag-battle#dragOver dragleave->drag-battle#dragLeave dragend->drag-battle#dragEnd'
    }
  end

  def data_fp_drawn_card
    { 'animations-target' => 'drawnCard' }
  end

  def board_space_data(first_person)
    data = { 'id' => @card.position }

    return data unless first_person

    data.tap do |hash|
      hash['drag-party-play-target'] = 'boardSpace'
      hash['action'] =
        'drop->drag-party-play#drop dragenter->drag-party-play#dragEnter dragover->drag-party-play#dragOver dragleave->drag-party-play#dragLeave dragend->drag-party-play#dragEnd'
    end
    data
  end
end
