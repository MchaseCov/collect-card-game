import { forwardRef } from 'react';
import html from '../htm_create_element';

import PlayerPortrait from '../shared/player_portrait';
import OpponentPlayerHand from './op_hand';

const playerClasslist = 'absolute bottom-0 left-0 right-0 w-36 h-44 mx-auto bg-red-200 rounded-t-full enemy-card';
const opponentDataset = { 'data-type': "player", 'data-gameplay-drag-target': 'recievesPlayerInput enemyActor', 'data-action': 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd' };

const createOpponentPlayerInfo = forwardRef((props, ref) => {
  return html`
  <section id='op-info' className="relative w-full h-1/4">
  ${PlayerPortrait(props.gameData.player_data, 'op', playerClasslist, opponentDataset)}
  <${OpponentPlayerHand} ref=${ref} cards=${props.gameData.cards.in_hand}/>
</section>
`;
})

export default createOpponentPlayerInfo