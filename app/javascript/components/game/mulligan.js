import { forwardRef } from 'react';
import html from '../htm_create_element';

import createOpponentPlayerInfo from '../opponent_player_side/op_info';
import MulliganPopUp from './mulligan_pop_up';
import Sidebar from './sidebar/sidebar';

const Mulligan = forwardRef((props, ref) => {
  const { gameData } = props;
  const {
    friendlyCardInMulliganReference, opponentCardInHandReference, thisGameReference, playersReference,
  } = ref.current;
  const gameInformationData = gameData.game;
  const playerInformationData = gameData.player.player_data;
  const opponentInformationData = gameData.opponent.player_data;
  const playerCardData = gameData.player.cards;
  const opponentCardData = gameData.opponent.cards;

  const opponentPlayerRefs = { opponentCardInHandReference, playersReference };

  return html`
    <div id="inner-game-container" className="absolute bottom-0 w-full max-w-[1920px] h-[123.5vh] mx-auto right-0 left-0 my-auto children-in-game-perspective">
    <${Sidebar}  gameInformationData=${gameInformationData} opponentInformationData=${opponentInformationData} playerInformationData=${playerInformationData} opponentCardData=${opponentCardData} playerCardData=${playerCardData} gameCurrentTurn=${true}/>
<article id="main-game-board"   className="flex flex-col content-between justify-between w-full h-full max-h-[1600px] mx-auto items-between flex-nowrap gap-y-6 xl:gap-y-2 overflow-clip bg-light-brown game-perspective-3d"
  data-controller="style-cards gameboard-animations" data-game=${gameInformationData.id}
  data-gameboard-animations-status-value=${gameInformationData.status}
  data-gameboard-animations-turn-value=${gameInformationData.turn_time} key="game-board" ref=${(el) => thisGameReference.current.gameBoardParent = el}
  >
  <${createOpponentPlayerInfo} key="opInfoRegion" ref=${opponentPlayerRefs} gameData=${gameData.opponent}/>
  <${MulliganPopUp} key="mulliganInfoRegion" ref=${friendlyCardInMulliganReference} playerData=${gameData.player}
    gameId=${gameInformationData.id} />
</article>
</div>
  `;
});

export default Mulligan;
