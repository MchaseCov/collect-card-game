import html from 'components/htm_create_element';
import { useState, useEffect, forwardRef } from 'react';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import Art from '../shared/art';
import StandardCard from './standard_card';

const classList = 'relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip';
const tooltipClassList = 'tooltip top-0 -left-44 z-50 shadow-2xl shadow-cyan-200'
const CardInBattle = forwardRef((props, ref) => {
  const [status, setStatus] = useState(props.status);

  useEffect(() => {
    const thisCardElement = ref.current[props.id];
    if (props.firstPerson && thisCardElement.dataset.status !== status) {
      const newStatus = thisCardElement.dataset.status;
      setStatus(newStatus);
      switch (newStatus) {
        case 'attack_ready':
          thisCardElement.draggable = true;
          thisCardElement.classList.add('ring');
          thisCardElement.dataset.action.replace('#errorFeedback', '#dragStart');
          break;
        default:
          thisCardElement.draggable = false;
          thisCardElement.classList.remove('ring');
          thisCardElement.dataset.action.replace('#dragStart', '#errorFeedback');
      }
    }
  });

  return html`
    <div id=${props.id} ref=${(el) => ref.current[props.id] = el} class=${[classList, props.additionalClasses].join(' ')} ...${props.dataset}>
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} />
    <${StandardCard} id=${`card_${props.id}_tooltip`}
                     cardConstant=${props.cardConstant}
                     health=${props.health}
                     attack=${props.attack}
                     health_cap=${props.health_cap}
                     additionalClasses=${tooltipClassList}
                     keywords=${props.keywords}
                     cost=${props.cost}
                    />
    <${AttackBubble} attack=${props.attack} />
    <${Art} rounded="true" />
    </div>
  `;
});

export default CardInBattle;
