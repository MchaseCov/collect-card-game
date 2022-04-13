import html from 'components/htm_create_element';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import Art from '../shared/art';

const classList = 'relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip';
export default function CardInBattle(props, dataset) {
  return html`
    <div id=${props.id} class=${classList} ...${dataset}>
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} />
    <${AttackBubble} attack=${props.attack} />
    <${Art} rounded="true" />
    </div>
  `;
}
