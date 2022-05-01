import { forwardRef } from "react";
import html from "../../htm_create_element";

import endTurnButton from './../end_turn_button';
import Deck from "./deck";

const Sidebar = forwardRef((props, ref) => {
const { gameInformationData ,opponentCardData ,playerCardData, gameCurrentTurn} = props
const {turnButton, undrawnCardReference} = ref || {}

return html`
<aside id="sidebar" className="absolute z-50 w-1/12 h-full right-5 -top-8 game-perspective-3d" key="game-sidebar">
  <div id="decks-container" className="absolute top-0 bottom-0 flex flex-col justify-between my-auto h-[700px]">
    <div className="preserve-3d" id="op-deck">
      <${Deck} cardsInDeck=${opponentCardData.in_deck} cardFromDeck=${opponentCardData.undrawnCard} ref=${undrawnCardReference}/>
    </div>
    <div className="preserve-3d" id="fp-deck" >
      <${Deck} cardsInDeck=${playerCardData.in_deck} cardFromDeck=${playerCardData.undrawnCard} ref=${undrawnCardReference}/>
    </div>
  </div>
  <${endTurnButton} key="turnButton" gameCurrentTurn=${gameCurrentTurn} ref=${turnButton} gameId=${gameInformationData.id} />
</aside>`

});

export default Sidebar