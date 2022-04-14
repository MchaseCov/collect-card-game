import html from './htm_create_element';

import Healthbubble from './shared/health_bubble';
import AttackBubble from './shared/attack_bubble';

export default function PlayerPortrait(props, id, classList, dataset) {
  return html`<div id='${id}-player-info'
                  key=${id}
                  class="${classList}"
                  data-status="${props.status}"
                  data-id="${props.id}"
                  data-player-id="${props.id}"
                  data-animations-target="player"
                  data-style-cards-target="player"
                  ...${dataset}>
                    <${Healthbubble} health=${props.health_current} healthCap=${props.health_cap} />
                    <${AttackBubble} attack=${props.attack}/>
              </div>`;
            }
