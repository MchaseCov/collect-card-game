import html from 'components/htm_create_element';
import { forwardRef } from 'react';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import CostBubble from '../shared/cost_bubble';
import NameBubble from '../shared/name';
import Art from '../shared/art';
import Keyword from '../shared/keyword';
import Tribe from '../shared/tribe';

const classList = 'w-40 text-white border-2 border-blackish rounded h-60 ';
const StandardCard = forwardRef((props, ref) => {
  const bubbleColor = props.type == "PartyCard" ? "amber" : "sky"
  const classColor = `bg-${props.cardConstant.archetypeColor}-700`
  return html`
    <div id=${props.id} className=${classList + props.additionalClasses} draggable=${props.draggable || false} ...${props.dataset} ref=${(el) => { if(ref) ref.current[props.id] = el}} >
    <${CostBubble} color=${bubbleColor} cost=${props.cost}/>
    <${NameBubble} name=${props.cardConstant.name} classColor=${classColor}/>
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} additionalClasses="w-10 h-10 text-3xl -bottom-3 -left-2" />
    <${AttackBubble} attack=${props.attack} additionalClasses=" w-10 h-10 text-3xl -bottom-3 -right-2" />
    <div className="absolute inset-x-0 h-24 text-xs text-center whitespace-normal border-t-2 rounded pointer-events-none select-none bottom-2 border-blackish ${classColor}">
    ${props.keywords.map((kw) => Keyword(kw))}
    </div>
    <${Tribe} tribe=${props.cardConstant.tribe} classColor=${classColor} />
    <${Art} />
    </div>
  `;
})

export default StandardCard
