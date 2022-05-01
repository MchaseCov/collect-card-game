import { forwardRef } from 'react';
import html from '../htm_create_element';

import Healthbubble from './health_bubble';
import AttackBubble from './attack_bubble';

const PlayerPortrait = forwardRef((props, ref) => {
  const {
    id, classList, dataSet, playerData,
  } = props;
  const classColor = `bg-${playerData.archetype.color}-700`;
  return html`<div id='${id}-player-info'
                  key=${id}
                  ref=${(el) => ref.current[playerData.id] = el}
                  className="${classList} ${classColor} portrait border-2 border-blackish transition-shadow hover:shadow-lg hover:shadow-white/70 w-36 h-44 2xl:w-40 2xl:h-48 has-tooltip"
                  data-status="${playerData.status}"
                  data-id="${playerData.id}"
                  data-player-id="${playerData.id}"
                  ...${dataSet}>
                  <div className="z-50 mx-auto text-xl text-center bg-white left-40 tooltip w-80 top-8 rounded-xl">
      Health Remaining: ${playerData.health_current} / ${playerData.health_cap} <br/>
      Race: ${playerData.race?.name} <br/>
      Archetype: ${playerData.archetype.name} <br/>
    </div>
      <${Healthbubble} health=${playerData.health_current} healthCap=${playerData.health_cap} additionalClasses="-bottom-3 -right-3"/>
      <${AttackBubble} attack=${playerData.attack} additionalClasses="-bottom-3 -left-3"/>
</div>`;
});

export default PlayerPortrait;
