import html from '../../components/htm_create_element';
import { forwardRef } from 'react';

import OpponentPlayerHand from './op_hand';
import PlayerPortrait from '../../components/player_portrait';

const playerClasslist = 'absolute bottom-0 left-0 right-0 w-40 h-48 mx-auto bg-red-200 rounded-t-full enemy-card';
const opponentDataset = {'data-type':"player", 'data-gameplay-drag-target': 'recievesPlayerInput enemyActor', 'data-action': 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd' };

const createOpponentPlayerInfo = forwardRef((props, ref) => {
  return html`
  <section id='op-info' className="relative w-full h-1/3">
  ${PlayerPortrait(props.gameData.player_data, 'op', playerClasslist, opponentDataset)}
  <${OpponentPlayerHand} ref=${ref} cards=${props.gameData.cards.in_hand}/>
</section>
`;
})

export default createOpponentPlayerInfo