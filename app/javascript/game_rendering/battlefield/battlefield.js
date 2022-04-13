import { render } from 'react-dom';

import createBattlefieldRow from './battlefield_row';

const battlefieldContainer = document.getElementById('battlefield');

const initialFriendlyBoardSpaceElement = {
  class: 'rounded-full opacity-50 board-space',
  'data-gameplay-drag-target': 'recievesPlayToBoard',
  'data-action': 'drop->gameplay-drag#boardspaceDrop dragenter->gameplay-drag#boardspaceDragEnter dragover->gameplay-drag#dragOver',
};

function friendlyPlayerCardDataset(card) {
  const data = {
    'data-style-cards-target': 'boardMinion',
    'data-gameplay-drag-target': 'recievesPlayerInput friendlyActor',
    'data-id': card.id,
    'data-status': card.status,
    'data-health-current': card.health,
    'data-health-cap': card.health_cap,
    'data-gameplay-drag-action-param': 'combat',
    'data-action': 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd',
    draggable: true,
  };
  if (card.taunting) data['data-style-cards-target'] += ' tauntingCard';
  return data;
}

function opponentPlayerCardDataset(card) {
  const data = {
    'data-style-cards-target': 'boardMinion',
    'data-gameplay-drag-target': 'recievesPlayerInput enemyActor',
    'data-id': card.id,
    'data-status': card.status,
    'data-health-current': card.health,
    'data-health-cap': card.health_cap,
    'data-type': 'party',
    'data-action': 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd',
  };
  if (card.taunting) {
    data['data-gameplay-drag-target'] += ' tauntingCard';
    data['data-style-cards-target'] += ' tauntingCard';
  }
  return data;
}

export default function createBattlefield(friendlyPlayerCards, opponentPlayerCards) {
  const battlefieldState = [createBattlefieldRow(opponentPlayerCards, { identifier: 'op', cardDataset: opponentPlayerCardDataset }),
    createBattlefieldRow(friendlyPlayerCards, { identifier: 'fp', boardSpaceData: initialFriendlyBoardSpaceElement, cardDataset: friendlyPlayerCardDataset })];
  render(battlefieldState, battlefieldContainer);
}
