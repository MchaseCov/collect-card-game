import html from '../htm_create_element';
import { forwardRef } from 'react';


import StandardCard from '../cards/standard_card';

const containerClasslist = 'w-full ml-auto text-center whitespace-nowrap z-20 preserve-3d children-in-game-perspective';
const cardInHandClassList = 'relative ring ring-glow-green playing-card preserve-3d inline-block -ml-10 z-10 card-in-hand hover:z-20 hover:bottom-8 hover:scale-125';

const partyCardAttributes = card => {
  const data = {
    'data-id': card.id,
    'data-resource': 'Cost',
    'data-cost': card.cost,
    'data-gameplay-drag-target': 'playsToBoard',
    'data-action': 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd',
    'data-gameplay-drag-type-param': 'party',
    'data-gameplay-drag-action-param': 'play_card',
  };
  const battlecry = card.keywords.find((c) => c.type === 'Battlecry');
  if (battlecry?.player_choice) {
    data['data-gameplay-drag-target-type-param'] = 'battlecry';
    data['data-battlecry'] = battlecry.id;
    data['data-gameplay-drag-target'] += ' takesPlayerInput';
  }
  return data;
}

const spellCardAttributes = card => {
  const data = {
    'data-id': card.id,
    'data-resource': 'Resource',
    'data-cost': card.cost,
    'data-gameplay-drag-target': 'spellCard',
    'data-action': 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd',
    'data-gameplay-drag-type-param': 'spell',
    'data-gameplay-drag-action-param': 'play_card',
  };
  const cast = card.keywords.find((c) => c.type === 'Cast');
  if (cast?.player_choice) {
    data['data-gameplay-drag-target-type-param'] = 'cast';
    data['data-cast'] = cast.id;
    data['data-gameplay-drag-target'] += ' takesPlayerInput';
  }
  return data;
}


const cardInHandDataAttributes = (card) => {
  switch (card.type) {
    case 'PartyCard':
      return partyCardAttributes(card)
    case 'SpellCard':
      return spellCardAttributes(card)
  }
};


const FriendlyPlayerHand = forwardRef((props, ref) => {
  const { cards } = props
  //const cardsInHand = cards.map((card) => StandardCard(card, cardInHandClassList, cardInHandDataAttributes(card)));

  return html`
  <div id='fp-cards-hand' className="${containerClasslist}" data-animations-target="hand">
    ${cards.map((card) => html`<${StandardCard} id=${card.id} 
                                                key=${card.id}
                                                cardConstant=${card.cardConstant}
                                                health=${card.health}
                                                attack=${card.attack}
                                                health_cap=${card.health_cap}
                                                dataset=${cardInHandDataAttributes(card)}
                                                additionalClasses=${cardInHandClassList}
                                                keywords=${card.keywords}
                                                cost=${card.cost}
                                                ref=${ref}
                                                type=${card.type}
                                                draggable=${true}
                                              />`)}
  </div>`;
});

export default FriendlyPlayerHand
