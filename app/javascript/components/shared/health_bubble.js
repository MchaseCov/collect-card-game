import html from 'components/htm_create_element';

const classList = 'absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center border-2 rounded-full pointer-events-none select-none health-current border-lime-600 bg-lime-500 right-0';

export default function Healthbubble(props) {
  if (props.health === null) return;
  const textColor = props.health < props.healthCap ? 'text-red-500' : 'text-white';
  return html`
    <div id="health" className=${[classList, textColor, props.additionalClasses].join(' ')} >
    ${props.health}
    </div>
  `;
}
