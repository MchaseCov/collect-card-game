import html from '../htm_create_element';

import Healthbubble from './health_bubble';
import AttackBubble from './attack_bubble';

import { useEffect, useState } from 'react';
import { raceIndexedDb } from '../../indexeddb/races';

export default function PlayerPortrait(props, id, classList, dataset) { 
  const classColor = `bg-${props.archetype.color}-700`
  console.log(props.health_current, props.race.name)
  return html`<div id='${id}-player-info'
                  key=${id}
                  className="${classList} ${classColor} portrait border-2 border-blackish transition-shadow hover:shadow-lg hover:shadow-white/70 w-36 h-44 2xl:w-40 2xl:h-48 has-tooltip"
                  data-status="${props.status}"
                  data-id="${props.id}"
                  data-player-id="${props.id}"
                  data-animations-target="player"
                  data-style-cards-target="player"
                  ...${dataset}>
                  <div className="z-50 mx-auto text-xl text-center bg-white left-40 tooltip w-80 top-8 rounded-xl">
      Health Remaining: ${props.health_current} / ${props.health_cap} <br/>
      Race: ${props.race.name} <br/>
      Archetype: ${props.archetype.name} <br/>
    </div>
                    <${Healthbubble} health=${props.health_current} healthCap=${props.health_cap} additionalClasses="-bottom-3 -right-3"/>
                    <${AttackBubble} attack=${props.attack} additionalClasses="-bottom-3 -left-3"/>
              </div>`;
}
