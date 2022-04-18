import html from '../../components/htm_create_element';

import createBattlefieldRow from './battlefield_row';
import StandardCard from '../../components/cards/standard_card';

import { forwardRef } from 'react';

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

const firstPersonCardClasses = 'hover:ring-offset-2 hover:ring-offset-lime-300 board-animatable z-40 ring ring-lime-500';

const firstPersonSpecificData = {identifier: 'fp', boardSpaceData: initialFriendlyBoardSpaceElement, cardDataset: friendlyPlayerCardDataset, cardClasses: firstPersonCardClasses, firstPerson: true }
const opponentSpecificData = { identifier: 'op', cardDataset: opponentPlayerCardDataset}

const createBattlefield = forwardRef((props, ref) => {
  const opponentCards = props.opponentCards
  const friendlyCards = props.friendlyCards

  let lastPlayedCardElement = (() => {
    if (props.lastPlayedCard) {
      const card = props.lastPlayedCard
      return html `<${StandardCard} id="animated-card"
      cardConstant=${card.cardConstant}
      health=${card.health}
      attack=${card.attack}
      health_cap=${card.health_cap}
      additionalClasses="absolute left-[15%] bottom-1/2 z-50"
      keywords=${card.keywords}
      cost=${card.cost}
     />`
    } else {
      return undefined
    }
  })();

  return html`
  <section id="battlefield" class="grid w-full grid-cols-1 grid-rows-2 h-1/3 rounded-2xl" data-animations-target="battlefield">
    ${lastPlayedCardElement}
    <${createBattlefieldRow} ref=${ref} cards=${opponentCards} playerSpecificData=${opponentSpecificData}/>
    <${createBattlefieldRow} ref=${ref} cards=${friendlyCards} playerSpecificData=${firstPersonSpecificData}/>
  </section>`
})
export default createBattlefield