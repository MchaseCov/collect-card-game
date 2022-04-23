import html from 'components/htm_create_element';

const classList = 'absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center text-white bg-red-500 border-2 border-red-600 rounded-full pointer-events-none select-none';

export default function AttackBubble(props) {
  const isHidden = props.attack <= 0 ? ' hidden ' : undefined;
  return html`
    <div id="attack" className=${[classList, isHidden, props.additionalClasses].join(' ')} >
      ${props.attack}
    </div>
  `;
}
