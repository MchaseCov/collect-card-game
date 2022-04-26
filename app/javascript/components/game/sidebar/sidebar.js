import { forwardRef } from "react";
import html from "../../htm_create_element";

import endTurnButton from './../end_turn_button';
import Deck from "./deck";

const Sidebar = forwardRef((props, ref) => {
  
  const { gameInformationData ,opponentInformationData ,playerInformationData ,opponentCardData ,playerCardData, gameCurrentTurn} = props


  const coins = amount => [...Array(amount)].map((_,i) =>html`<i key=${i} className="pt-2 pl-2 text-xl fas fa-circle text-amber-400"></i>`)
  const resource = amount => [...Array(amount)].map((_,i) =>html`<i  key=${i} className="pb-2 pl-2 text-lg fas fa-star text-sky-400"></i>`)

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

  <section id="op-deck" className="absolute flex flex-row gap-x-3">
    <div>
    <div className="relative min-w-max">Gold: ${opponentInformationData.cost_current} / ${opponentInformationData.cost_cap}</div>
    <div className="min-w-max">Resource: ${opponentInformationData.resource_current} / ${opponentInformationData.resource_cap}</div>
    <div className="relative text-center has-tooltip">
    <div className="top-0 px-3 py-1 mx-auto text-center bg-white right-40 tooltipleft-0 tooltip w-max rounded-xl">
      Cards remaining in opponent's deck: ${opponentCardData.in_deck}. <br/>
      Cards in opponent's hand: ${opponentCardData.in_hand.length}.
      </div>
    </div>
  </div>
  </section>
<${endTurnButton} key="turnButton" gameCurrentTurn=${gameCurrentTurn} ref=${ref} gameId=${gameInformationData.id} />
<section id="fp-deck" className="absolute flex flex-row flex-col gap-x-3 flex-nowrap bottom-5">
  <div className="relative text-center has-tooltip">
    <div className="bottom-0 px-3 py-1 mx-auto text-center bg-white right-40 tooltip w-max rounded-xl">
      Cards remaining in your deck: ${playerCardData.in_deck}. <br/>
      Cards in your hand: ${playerCardData.in_hand.length}.
    </div>
  </div>
  <div className="absolute bottom-0 mr-2 right-40 w-96">
    <div key="fp-cc" className="w-full h-8 bg-gray-400">
      ${coins(playerInformationData.cost_current)}
    </div>
    <div key="fp-rc" className="w-full h-8 bg-gray-400">
      ${resource(playerInformationData.resource_current)}
    </div>
  </div>
</section>
</aside>`

});

export default Sidebar