import html from '../../components/htm_create_element';

const cardInHandTooltipClassList = 'left-0 right-0 text-center tooltip -bottom-10';
const cardInHandClassList = 'relative inline-block w-40 -mt-12 -ml-10 text-white border-2 border-black rounded h-60 max-h-60 bg-slate-700';
const containerClasslist = 'absolute flex-1 w-full ml-auto text-center has-tooltip shrink flex-nowrap whitespace-nowrap -top-16';

const hoverTooltip = (count) => {
  const plural = count > 1 ? 's' : null;
  return html`<div class=${cardInHandTooltipClassList}>Your opponent has ${count} card${plural} in hand. </div>`;
};

const cardInHand = (id) => html`<div id=${id} class=${cardInHandClassList} />`;

export default function OpponentPlayerHand(handData) {
  const cardsInHand = handData.map((id) => cardInHand(id));

  return html`<div id='op-cards-hand'
        class="${containerClasslist}"
        data-animations-target="hand"
        >
        ${hoverTooltip(cardsInHand.length)}
        ${cardsInHand}
        </div>`;
}
