import { forwardRef } from "react";
import html from "../../htm_create_element";

import endTurnButton from './../end_turn_button';

const Sidebar = forwardRef((props, ref) => {

 const { gameInformationData ,opponentInformationData ,playerInformationData ,opponentCardData ,playerCardData, gameCurrentTurn} = props

return html`
<aside id="sidebar" className="fixed z-50 w-1/12 h-full right-5" key="game-sidebar">
  <section id="op-deck" className="absolute flex flex-row gap-x-3">
    <div>
    <div className="relative min-w-max">Gold: ${opponentInformationData.cost_current} / ${opponentInformationData.cost_cap}</div>
    <div className="min-w-max">Resource: ${opponentInformationData.resource_current} / ${opponentInformationData.resource_cap}</div>
    <div className="relative w-40 text-center border-2 rounded border-blackish h-60 bg-card-blue has-tooltip">
    <div className="top-0 px-3 py-1 mx-auto text-center bg-white right-40 tooltipleft-0 tooltip w-max rounded-xl">
      Cards remaining in opponent's deck: ${opponentCardData.in_deck}. <br/>
      Cards in opponent's hand: ${opponentCardData.in_hand.length}.
      </div>
    </div>
  </div>
  </section>
<${endTurnButton} key="turnButton" gameCurrentTurn=${gameCurrentTurn} ref=${ref} gameId=${gameInformationData.id} />
  <section id="fp-deck" className="absolute flex flex-row flex-col gap-x-3 flex-nowrap bottom-5">
    <div className="relative w-40 text-center border-2 border-[#14080E] rounded h-60 bg-card-blue has-tooltip">
      <div className="bottom-0 px-3 py-1 mx-auto text-center bg-white right-40 tooltipleft-0 tooltip w-max rounded-xl">
      Cards remaining in your deck: ${playerCardData.in_deck}. <br/>
      Cards in your hand: ${playerCardData.in_hand.length}.
      </div>
    </div>
    <div className="min-w-max">Gold: ${playerInformationData.cost_current} / ${playerInformationData.cost_cap}</div>
    <div className="min-w-max">Resource: ${playerInformationData.resource_current} / ${playerInformationData.resource_cap}</div>
  </section>
</aside>`

});

export default Sidebar