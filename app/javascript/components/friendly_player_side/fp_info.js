import { forwardRef } from 'react';
import html from '../htm_create_element';

import FriendlyPlayerHand from './fp_hand';
import PlayerPortrait from '../shared/player_portrait';

const coins = (amount) => [...Array(amount)].map((_, i) => html`<i key=${i} className="pt-2 pl-2 mb-1 text-xl fas fa-circle text-amber-400"></i>`);
const resource = (amount) => [...Array(amount)].map((_, i) => html`<i  key=${i} className="pb-2 pl-2 mt-1 text-lg fas fa-star text-sky-400"></i>`);

const playerClasslist = 'relative left-0 right-0 mx-auto rounded-t-full top-0';

const createFriendlyPlayerInfo = forwardRef((props, ref) => {
  const { friendlyCardInHandReference } = ref;
  const { playersReference } = ref;
  const playerGameData = props.gameData;
  return html`
  <section id='fp-info' className="relative bottom-0 w-full h-1/4">
    <div key="fp-cc" className="absolute h-8 mx-auto bg-gray-400 resource-bar rounded-xl right-1/2 w-80 has-tooltip">
      ${coins(playerGameData.player_data.cost_current)}
      <div className="z-50 mx-auto text-xl text-center bg-white w-80 -left-20 top-8 tooltip rounded-xl">
        You have ${playerGameData.player_data.cost_current} coins remaining to spend this turn. Every turn your
        coins replenish to the cap, up to 10.
      </div>
    </div>
    <div key="fp-rc" className="absolute h-8 mx-auto text-right bg-gray-400 resource-bar rounded-xl left-1/2 w-80 has-tooltip">
      ${resource(playerGameData.player_data.resource_current)}
      <div className="z-50 mx-auto text-xl text-center bg-white -right-20 w-80 top-8 tooltip rounded-xl">
        You have ${playerGameData.player_data.resource_current} resource points to spend this turn. Every turn your
        resource points replenish by 1, up to 10.
      </div>
    </div>
    <${PlayerPortrait}  playerData=${playerGameData.player_data} id='fp' classList=${playerClasslist} ref=${playersReference}/>
    <${FriendlyPlayerHand} ref=${friendlyCardInHandReference} cards=${playerGameData.cards.in_hand}/>
  </section>
`;
});

export default createFriendlyPlayerInfo;
