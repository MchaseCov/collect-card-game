import html from '../htm_create_element';

import Healthbubble from './health_bubble';
import AttackBubble from './attack_bubble';

export default function PlayerPortrait(props, id, classList, dataset) {
  return html`<div id='${id}-player-info'
                  key=${id}
                  className="${classList} border-2 border-blackish transition-shadow hover:shadow-lg hover:shadow-white/70 w-36 h-44 2xl:w-40 2xl:h-48"
                  data-status="${props.status}"
                  data-id="${props.id}"
                  data-player-id="${props.id}"
                  data-animations-target="player"
                  data-style-cards-target="player"
                  ...${dataset}>
                    <${Healthbubble} health=${props.health_current} healthCap=${props.health_cap} additionalClasses="-bottom-3 -right-3"/>
                    <${AttackBubble} attack=${props.attack} additionalClasses="-bottom-3 -left-3"/>
              </div>`;
}
