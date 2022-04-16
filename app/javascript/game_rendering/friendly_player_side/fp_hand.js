import html from 'components/htm_create_element';

import StandardCard from '../../components/cards/standard_card';

const containerClasslist = 'absolute w-full ml-auto text-center whitespace-nowrap -bottom-32 hover:bottom-0';
const cardInHandClassList = 'relative ring ring-lime-500 playing-card inline-block -ml-10 z-10 hover:z-20 hover:bottom-8 hover:scale-125';
const cardInHandDataAttributes = (card) => {
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
    data['data-battlecry']= battlecry.id;
    data['data-gameplay-drag-target'] += ' takesPlayerInput';
  }
  return data;
};

export default function FriendlyPlayerHand(props) {
  const cardsInHand = props.map((card) => StandardCard(card, cardInHandClassList, cardInHandDataAttributes(card)));

  return html`<div id='fp-cards-hand' class="${containerClasslist}" data-animations-target="hand">
        ${cardsInHand}
        </div>`;
}
