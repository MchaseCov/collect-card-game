import html from 'components/htm_create_element';

const classList = (color) => `absolute z-10 w-10 h-10 text-3xl text-center text-white border-2 rounded-full pointer-events-none select-none border-${color}-600 bg-${color}-500 -top-3 -left-3`;

export default function CostBubble(props) {
  return html`
    <div id="cost" className=${classList(props.color)} >
    ${props.cost}
    </div>
  `;
}
