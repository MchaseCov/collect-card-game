import { forwardRef } from 'react';
import html from '../htm_create_element';

const cardInHandTooltipClassList = 'left-0 right-0 text-center tooltip -bottom-10 bg-white w-max px-3 py-1 text-center right-0 left-0 mx-auto rounded-xl';
const cardInHandClassList = 'relative inline-block w-40 -mt-12 -ml-10 text-white border-2 border-blackish rounded h-48 max-h-60 bg-card-blue';
const containerClasslist = 'absolute flex-1 w-full ml-auto text-center has-tooltip shrink flex-nowrap whitespace-nowrap -top-16';

const hoverTooltip = (count) => {
  const plural = count > 1 ? 's' : null;
  return html`<div className=${cardInHandTooltipClassList}>Your opponent has ${count} card${plural} in hand. </div>`;
};

const cardInHand = forwardRef((props, ref) => { return html`<div id=${props.id} className=${cardInHandClassList} ref=${(el) => { ref.current[props.id] = el }}/>`; })

const OpponentPlayerHand = forwardRef((props, ref) => {
  const { cards } = props
  return html`<div id='op-cards-hand'
        className="${containerClasslist}"
        data-animations-target="hand"
        >
        ${hoverTooltip(cards.length)}
        ${cards.map((card) => html`<${cardInHand} id=${card} ref=${ref} key=${card}/>`)}
        </div>`;
})

export default OpponentPlayerHand