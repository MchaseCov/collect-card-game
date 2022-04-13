import html from 'components/htm_create_element';

import Healthbubble from '../shared/health_bubble';
import AttackBubble from '../shared/attack_bubble';
import CostBubble from '../shared/cost_bubble';
import NameBubble from '../shared/name';
import Art from '../shared/art';
import Keyword from '../shared/keyword';
import Tribe from '../shared/tribe';

const classList = 'w-40 text-white border-2 border-black rounded h-60 ';

export default function StandardCard(props, cardInHandClassList, dataset) {
  return html`
    <div id=${props.id} class=${classList + cardInHandClassList} draggable="true" ...${dataset} >
    <${CostBubble} cost=${props.cost}/>
    <${NameBubble} name=${props.cardConstant.name}/>
    <${Healthbubble} health=${props.health} healthCap=${props.health_cap} additionalClasses="w-10 h-10 text-3xl -bottom-2" />
    <${AttackBubble} attack=${props.attack} additionalClasses=" w-10 h-10 text-3xl -bottom-2" />
    <div class="text-center text-xs absolute bottom-2 inset-x-0 border-2 rounded border-slate-900 bg-red-700 h-24 whitespace-normal pointer-events-none select-none">
    ${props.keywords.map((kw) => Keyword(kw))}
    </div>
    <${Tribe} tribe=${props.tribe} />
    <${Art} />
    </div>
  `;
}
