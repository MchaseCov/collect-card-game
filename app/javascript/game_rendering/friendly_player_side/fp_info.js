import html from '../../components/htm_create_element';
import { forwardRef } from 'react';

import FriendlyPlayerHand from './fp_hand';
import PlayerPortrait from '../../components/player_portrait';

const playerClasslist = 'absolute left-0 right-0 w-40 h-48 mx-auto bg-blue-200 rounded-t-full top-0';

const createFriendlyPlayerInfo = forwardRef((props, ref) => {
  const playerGameData  = props.gameData
  return html`
  <section id='fp-info' className="relative w-full h-1/3">
  ${PlayerPortrait(playerGameData.player_data, 'fp', playerClasslist)}
  <${FriendlyPlayerHand} ref=${ref} cards=${playerGameData.cards.in_hand}/>
  
  </section>
`;
})

export default createFriendlyPlayerInfo
