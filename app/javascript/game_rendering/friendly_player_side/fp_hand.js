import html from 'components/htm_create_element';

import StandardCard from '../../components/cards/standard_card';

const containerClasslist = 'absolute w-full ml-auto text-center whitespace-nowrap -bottom-32 hover:bottom-0';
const cardInHandClassList = 'relative ring ring-lime-500 playing-card inline-block -ml-10 z-10 hover:z-20 hover:bottom-8 hover:scale-125';
const cardInHandDataAttributes = (card) => {
  const data = {
    id: card.id,
    resource: 'Cost',
    cost: card.cost,
    'gameplay-drag-target': 'playsToBoard',
    action: 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd',
    'gameplay-drag-type-param': 'party',
    'gameplay-drag-action-param': 'play_card',
  };
  if (card.keywords.find((c) => c.type === 'Battlecry')?.player_choice) {
    data['gameplay-drag-target-type-param'] = 'battlecry';
    data.battlecry = battlecry.id;
    data['gameplay-drag-target'] += ' takesPlayerInput';
  }
  return data;
};

export default function FriendlyPlayerHand(props) {
  const cardsInHand = props.map((card) => StandardCard(card, cardInHandClassList, cardInHandDataAttributes(card)));

  return html`<div id='fp-cards-hand' class="${containerClasslist}" data-animations-target="hand">
        ${cardsInHand}
        </div>`;
}
