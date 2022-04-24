import html from '../htm_create_element';
import { forwardRef } from 'react';

import FriendlyPlayerHand from './fp_hand';
import PlayerPortrait from '../shared/player_portrait';

const playerClasslist = 'absolute left-0 right-0 mx-auto bg-blue-200 rounded-t-full top-0';

const createFriendlyPlayerInfo = forwardRef((props, ref) => {
  const playerGameData = props.gameData
  return html`
  <section id='fp-info' className="absolute bottom-0 w-full h-1/3">
  ${PlayerPortrait(playerGameData.player_data, 'fp', playerClasslist)}
  <${FriendlyPlayerHand} ref=${ref} cards=${playerGameData.cards.in_hand}/>
  
  </section>
`;
})

export default createFriendlyPlayerInfo
