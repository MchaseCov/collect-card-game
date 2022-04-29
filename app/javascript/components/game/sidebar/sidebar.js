import { forwardRef } from "react";
import html from "../../htm_create_element";

import endTurnButton from './../end_turn_button';
import Deck from "./deck";

const Sidebar = forwardRef((props, ref) => {
  
  const { gameInformationData ,opponentCardData ,playerCardData, gameCurrentTurn} = props

return html`
<aside id="sidebar" className="absolute z-50 w-1/12 h-full right-5 -top-8 game-perspective-3d" key="game-sidebar">
  <div id="decks-container" className="absolute top-0 bottom-0 flex flex-col justify-between my-auto h-[700px]">
    <div className="preserve-3d" >
      <${Deck} cardsInDeck=${opponentCardData.in_deck}/>
    </div>
    <div className="preserve-3d" >
      <${Deck} cardsInDeck=${playerCardData.in_deck}/>
    </div>
  </div>


<${endTurnButton} key="turnButton" gameCurrentTurn=${gameCurrentTurn} ref=${ref} gameId=${gameInformationData.id} />

</aside>`

});

export default Sidebar