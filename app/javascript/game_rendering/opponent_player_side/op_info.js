import { render } from 'react-dom';

import OpponentPlayerHand from './op_hand';
import PlayerPortrait from '../../components/player_portrait';

const opInfoContainer = document.getElementById('op-info');
const playerClasslist = 'absolute bottom-0 left-0 right-0 w-40 h-48 mx-auto bg-red-200 rounded-t-full enemy-card';
const opponentDataset = { gameplayDragTarget: 'recievesPlayerInput enemyActor', action: 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd' };

export default function createOpponentPlayerInfo(data) {
  const playerInfo = [PlayerPortrait(data.player_data, 'op', playerClasslist, opponentDataset), OpponentPlayerHand(data.cards.in_hand)];
  render(playerInfo, opInfoContainer);
}
