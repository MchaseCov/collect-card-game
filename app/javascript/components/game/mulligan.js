import html from '../htm_create_element';
import { forwardRef } from 'react';

import createOpponentPlayerInfo from '../opponent_player_side/op_info';
import MulliganPopUp from './mulligan_pop_up';


const Mulligan = forwardRef((props, ref) => {
  const { gameData } = props;
  const { friendlyCardInMulliganReference, opponentCardInHandReference, thisGameReference } = ref.current
  const gameInformationData = gameData.game
  const playerInformationData = gameData.player.player_data
  const playerCardData = gameData.player.cards
  const opponentCardData = gameData.opponent.cards

  return html`
<aside id="sidebar" className="fixed right-0 z-50 w-1/12 h-full" key="game-sidebar">
  <section id="op-deck" className="absolute flex flex-row gap-x-3 top-5">
    <div className="relative w-40 text-center text-white border-2 border-blackish rounded h-60 bg-card-blue">
      In Deck: ${opponentCardData.in_deck}
    </div>
  </section>
  <section id="fp-deck" className="absolute flex flex-row flex-col gap-x-3 flex-nowrap bottom-5">
    <div className="relative w-40 text-center text-white border-2 border-blackish rounded h-60 bg-card-blue">
      In Deck: ${playerCardData.in_deck}
    </div>
    <div className="min-w-max">Gold: ${playerInformationData.cost_current} / ${playerInformationData.cost_cap}</div>
  </section>
</aside>
<article id="main-game-board" className="flex flex-col h-full flex-nowrap gap-y-6 overflow-clip xl:gap-y-2"
  data-controller="style-cards gameboard-animations" data-game=${gameInformationData.id}
  data-gameboard-animations-status-value=${gameInformationData.status}
  data-gameboard-animations-turn-value=${gameInformationData.turn_time} key="game-board" ref=${(el)=>
  thisGameReference.current.gameBoardParent = el}
  >
  <${createOpponentPlayerInfo} key="opInfoRegion" ref=${opponentCardInHandReference} gameData=${gameData.opponent} />
  <${MulliganPopUp} key="mulliganInfoRegion" ref=${friendlyCardInMulliganReference} playerData=${gameData.player}
    gameId=${gameInformationData.id} />
</article>
  `;
});

export default Mulligan
