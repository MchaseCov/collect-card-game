import html from 'components/htm_create_element';
import { forwardRef, useState, useEffect, useRef } from 'react';

import createOpponentPlayerInfo from './opponent_player_side/op_info';
import createFriendlyPlayerInfo from './friendly_player_side/fp_info';
import createBattlefield from './battlefield/battlefield';

const Game = forwardRef((props, ref) => {
  const { gameData } = props;
  const { cardInBattleReference, friendlyCardInHandReference,  opponentCardInHandReference } = ref.current
  const gameInformationData = gameData.game
  const playerInformationData = gameData.player.player_data
  const playerCardData = gameData.player.cards
  const opponentCardData = gameData.opponent.cards
  const [firstPersonPlayerTurn] = useState(playerInformationData.turn_order);
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');

  // Disable button when it is not the current player's turn
  const turnButton = useRef(null);
  const [currentTurn, setTurn] = useState(gameInformationData.turn);
  if (currentTurn !== gameInformationData.turn) setTurn(gameInformationData.turn);
  useEffect(() => { turnButton.current.disabled = (currentTurn !== firstPersonPlayerTurn); }, [currentTurn]);

  return html`
<aside id="sidebar" className="fixed right-0 z-50 w-1/12 h-full" key="game-sidebar">
  <section id="op-deck" className="absolute flex flex-row gap-x-3 top-5">
    <div className="relative w-40 text-center text-white border-2 border-black rounded h-60 bg-slate-700">
      In Deck: ${opponentCardData.in_deck}
    </div>
  </section>
  <section id="turn-button" className="absolute top-1/2 bottom 1/2">
    ${currentTurn ? 'Player 1' : 'Player 2'}'s Turn!
    <form className="button_to" method="post" action="/games/${gameInformationData.id}/end_turn">
      <button ref=${turnButton} className="px-4 py-2 font-bold text-white bg-blue-500 rounded disabled:bg-gray-200" type="submit">End Turn</button>
      <input type="hidden" name="authenticity_token" value=${csrf} /> 
    </form>
  </section>
  <section id="fp-deck" className="absolute flex flex-row flex-col gap-x-3 flex-nowrap bottom-5">
    <div className="relative w-40 text-center text-white border-2 border-black rounded h-60 bg-slate-700">
      In Deck: ${playerCardData.in_deck}
    </div>
    <div className="min-w-max">Gold: ${playerInformationData.cost_current} / ${playerInformationData.cost_cap}</div>
  </section>
</aside>
<article id="main-game-board"
        className="flex flex-col h-full flex-nowrap gap-y-6 overflow-clip xl:gap-y-2"
        data-controller="gameplay-drag line-drawer style-cards gameboard-animations"
        data-game=${gameInformationData.id}
        data-gameboard-animations-status-value=${gameInformationData.status}
        data-gameboard-animations-turn-value=${gameInformationData.turn_time}
        key="game-board">
        >
  <canvas id="drawContainer" data-line-drawer-target="canvas" width="0" height="0" className='fixed z-50 pointer-events-none select-none'></canvas>
  <${createOpponentPlayerInfo} key="opInfoRegion" ref=${opponentCardInHandReference} gameData=${gameData.opponent}/>
  <${createBattlefield} key="battlefieldRegion" ref=${cardInBattleReference} friendlyCards=${playerCardData.in_battlefield} opponentCards=${opponentCardData.in_battlefield} lastPlayedCard=${gameData.lastPlayedCard}/>
  <${createFriendlyPlayerInfo} key="fpInfoRegion" ref=${friendlyCardInHandReference} gameData=${gameData.player}/>
</article>
  `;
})

export default Game
