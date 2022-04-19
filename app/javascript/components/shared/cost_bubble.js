import html from 'components/htm_create_element';

const classList = 'absolute z-10 w-10 h-10 text-3xl text-center text-white border-2 rounded-full pointer-events-none select-none border-amber-600 bg-amber-500 -top-2 -left-2';

export default function CostBubble(props) {
  return html`
    <div id="cost" className=${classList} >
    ${props.cost}
    </div>
  `;
}
