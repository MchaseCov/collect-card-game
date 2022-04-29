import html from '../htm_create_element';

import createBattlefieldRow from './battlefield_row';
import StandardCard from '../../components/cards/standard_card';

import { forwardRef } from 'react';

const initialFriendlyBoardSpaceElement = {
  className: 'rounded-full opacity-50 board-space',
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

const firstPersonCardClasses = 'hover:ring-offset-2 hover:ring-offset-lime-300 board-animatable z-40 ring ring-glow-green';

const firstPersonSpecificData = { identifier: 'fp', boardSpaceData: initialFriendlyBoardSpaceElement, cardDataset: friendlyPlayerCardDataset, cardClasses: firstPersonCardClasses, firstPerson: true }
const opponentSpecificData = { identifier: 'op', cardDataset: opponentPlayerCardDataset }

const createBattlefield = forwardRef((props, ref) => {
  const opponentCards = props.opponentCards
  const friendlyCards = props.friendlyCards

  let lastPlayedCardElement = (() => {
    if (props.lastPlayedCard) {
      const card = props.lastPlayedCard
      return html`<${StandardCard} id="animated-card"
      cardConstant=${card.cardConstant}
      health=${card.health}
      attack=${card.attack}
      health_cap=${card.health_cap}
      additionalClasses="absolute left-[15%] bottom-1/2 z-50"
      keywords=${card.keywords}
      cost=${card.cost}
      key=${card.id}
     />`
    } else {
      return ''
    }
  })();

  return html`
  <section id="battlefield" className="grid  preserve-3d z-10 items-stretch flex-1 max-h-[50%] w-full grid-cols-1 grid-rows-2 gap-0 mx-auto border-t-2 border-b-2 rounded-2xl">
    ${lastPlayedCardElement}
    <${createBattlefieldRow} key="OpBattlefield" ref=${ref} cards=${opponentCards} playerSpecificData=${opponentSpecificData}/>
    <${createBattlefieldRow} key="FpBattlefield" ref=${ref} cards=${friendlyCards} playerSpecificData=${firstPersonSpecificData}/>
  </section>`
})
export default createBattlefield