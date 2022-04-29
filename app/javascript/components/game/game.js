import html from '../htm_create_element';
import { forwardRef, useState, useEffect, useRef } from 'react';

import createOpponentPlayerInfo from '../opponent_player_side/op_info';
import createFriendlyPlayerInfo from '../friendly_player_side/fp_info';
import createBattlefield from '../battlefield/battlefield';
import Sidebar from './sidebar/sidebar';
import turnTimer from '../battlefield/turn_timer';


const Game = forwardRef((props, ref) => {
  const { gameData } = props;
  const { cardInBattleReference, friendlyCardInHandReference, opponentCardInHandReference, thisGameReference } = ref.current
  const gameInformationData = gameData.game
  const playerInformationData = gameData.player.player_data
  const opponentInformationData = gameData.opponent.player_data
  const playerCardData = gameData.player.cards
  const opponentCardData = gameData.opponent.cards

  // Disable button when it is not the current player's turn
  const turnButton = useRef(null);

  const [gameCurrentTurn, setTurn] = useState(gameInformationData.turn);
  if (gameCurrentTurn !== gameInformationData.turn) setTurn(gameInformationData.turn);
  const playersTurnOrder = playerInformationData.turn_order
  const isPlayersTurn = playersTurnOrder === gameCurrentTurn

  useEffect(() => { turnButton.current.disabled = !isPlayersTurn })

  return html`
  <canvas id="drawContainer" data-line-drawer-target="canvas" width="0" height="0" className='fixed bottom-0 left-0 right-0 z-50 mx-auto pointer-events-none select-none'></canvas>
  <div id="inner-game-container" className="absolute bottom-0 w-full max-w-[1920px] h-[123.5vh] mx-auto right-0 left-0 my-auto children-in-game-perspective">
  <${Sidebar} ref=${turnButton} gameInformationData=${gameInformationData} opponentInformationData=${opponentInformationData} playerInformationData=${playerInformationData} opponentCardData=${opponentCardData} playerCardData=${playerCardData} gameCurrentTurn=${gameCurrentTurn}/>
  <article id="main-game-board"
  className="flex flex-col content-between justify-between w-full h-full max-h-[1600px] mx-auto items-between flex-nowrap gap-y-6 xl:gap-y-2 overflow-clip bg-light-brown game-perspective-3d"
  data-controller="gameplay-drag style-cards gameboard-animations"
  data-game=${gameInformationData.id}
  data-gameboard-animations-status-value=${gameInformationData.status}
  data-gameboard-animations-turn-value=${gameInformationData.turn_time}
  key="game-board"
  ref=${(el) => thisGameReference.current.gameBoardParent = el}
  >
  <${createOpponentPlayerInfo} key="opInfoRegion" ref=${opponentCardInHandReference} gameData=${gameData.opponent}/>
  <${createBattlefield} key="battlefieldRegion" ref=${cardInBattleReference} friendlyCards=${playerCardData.in_battlefield} opponentCards=${opponentCardData.in_battlefield} lastPlayedCard=${gameData.lastPlayedCard}/>
  <${createFriendlyPlayerInfo} key="fpInfoRegion" ref=${friendlyCardInHandReference} gameData=${gameData.player}/>
</article>
</div>
`;
})
//  <${turnTimer} turnTime=${props.turnTime} key=${props.turnTime} turnTime=${gameInformationData.turn_time} gameId=${gameInformationData.id} isPlayersTurn=${isPlayersTurn }/>

export default Game
