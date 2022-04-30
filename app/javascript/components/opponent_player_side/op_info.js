import { forwardRef } from 'react';
import html from '../htm_create_element';

import PlayerPortrait from '../shared/player_portrait';
import OpponentPlayerHand from './op_hand';

const coins = (amount) => [...Array(amount)].map((_, i) => html`<i key=${i} className="pt-2 pl-2 mb-1 text-xl fas fa-circle text-amber-400"></i>`);
const resource = (amount) => [...Array(amount)].map((_, i) => html`<i  key=${i} className="pb-2 pl-2 mt-1 text-lg fas fa-star text-sky-400"></i>`);

const playerClasslist = 'absolute bottom-0 left-0 right-0 mx-auto rounded-t-full enemy-card';
const opponentDataset = { 'data-type': 'player', 'data-gameplay-drag-target': 'recievesPlayerInput enemyActor', 'data-action': 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd' };

const createOpponentPlayerInfo = forwardRef((props, ref) => {
  const oppCardInHandReference = ref.opponentCardInHandReference;
  const { playersReference } = ref;

  return html`
  <section id='op-info' className="relative w-full h-1/4">
  <div key="op-cc" className="absolute h-8 mx-auto bg-gray-400 resource-bar bottom-1/2 rounded-xl right-1/2 w-80 has-tooltip">
        ${coins(props.gameData.player_data.cost_current)}
    </div>  
    <div key="op-rc" className="absolute h-8 mx-auto text-right bg-gray-400 resource-bar bottom-1/2 rounded-xl left-1/2 w-80 has-tooltip">
      ${resource(props.gameData.player_data.resource_current)}
    </div>
  <${PlayerPortrait}  playerData=${props.gameData.player_data} id='op' classList=${playerClasslist} dataSet=${opponentDataset} ref=${playersReference}/>
  <${OpponentPlayerHand} ref=${oppCardInHandReference} cards=${props.gameData.cards.in_hand}/>
</section>
`;
});

export default createOpponentPlayerInfo;
