import html from 'components/htm_create_element';
import { useState, useEffect, forwardRef } from 'react';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import Art from '../shared/art';
import StandardCard from './standard_card';

const classList = 'relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip';
const tooltipClassList = 'tooltip top-0 -left-44 z-50 shadow-2xl shadow-cyan-200 pointer-events-none select-none'
const CardInBattle = forwardRef((props, ref) => {
  const [status, setStatus] = useState(props.status);

  useEffect(() => {
    const thisCardElement = ref.current[props.id];
    if (props.firstPerson) {
      switch (status) {
        case 'attack_ready':
          thisCardElement.setAttribute('data-gameplay-drag-target', 'recievesPlayerInput friendlyActor')

          break;
        default:
          thisCardElement.setAttribute('data-gameplay-drag-target', 'recievesPlayerInput inactiveFriendlyActor')

      }
    }
  },[status]);

  if (props.status !== status) setStatus(props.status)

  return html`
    <div id=${props.id} ref=${(el) => ref.current[props.id] = el} className=${[classList, props.additionalClasses].join(' ')} ...${props.dataset}>
    <${StandardCard} id=${`card_${props.id}_tooltip`}
                     cardConstant=${props.cardConstant}
                     health=${props.health}
                     attack=${props.attack}
                     health_cap=${props.health_cap}
                     additionalClasses=${tooltipClassList}
                     keywords=${props.keywords}
                     cost=${props.cost}
                    />
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} />
    <${AttackBubble} attack=${props.attack} />
    <${Art} rounded="true" />
    </div>
  `;
});

export default CardInBattle;
