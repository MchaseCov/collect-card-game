import html from 'components/htm_create_element';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import Art from '../shared/art';

import StandardCard from './standard_card';

const classList = 'relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip';
export default function CardInBattle(props, dataset, additionalClasses) {
  const tooltip = StandardCard(props, 'tooltip top-0 -left-44 z-50 shadow-2xl shadow-cyan-200', undefined, `card_${props.id}_tooltip`)

  return html`
    <div id=${props.id} class=${[classList, additionalClasses].join(' ')} ...${dataset}>
    ${tooltip}
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} />
    <${AttackBubble} attack=${props.attack} />
    <${Art} rounded="true" />
    </div>
  `;
}
