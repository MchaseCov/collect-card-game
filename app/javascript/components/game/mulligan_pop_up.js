import { forwardRef } from "react";
import html from '../htm_create_element';

import StandardCard from "../cards/standard_card";

const MulliganPopUp = forwardRef((props, ref) => {
  console.log(props)
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');



  const playerMulliganInformationBox = (props) => {
    return html`
    <div key="mulliganInfoBox" id="mulligan-info-box">
      <h2>You are going ${props.playerData.player_data.turn_order ? "first" : "second"}</h2>
      <h3>You can choose to keep this starting hand, or to replace it once before starting</h3>
      <div className="flex flex-row justify-center mt-3 text-center gap-x-5">
        <form className="button_to" method="post" action="/games/${props.gameId}/submit_mulligan">
          <button className="px-5 py-2 my-2 text-white bg-green-500 rounded" type="submit">Keep cards</button>
          <input type="hidden" name="authenticity_token" value=${csrf} />
        </form>
        <form className="button_to" method="post" action="/games/${props.gameId}/submit_mulligan?mulligan=true">
          <button className="px-5 py-2 my-2 text-white bg-blue-500 rounded" type="submit">Redo cards</button>
          <input type="hidden" name="authenticity_token" value=${csrf} />
        </form>
      </div>
    </div>`
  }

  const playerMulliganWaitingBox = () => html`<h2 key="mulliganInfoBox" id="mulligan-info-box"> Waiting on opponent to finish mulligan. This is your
  starting hand.</h2>`


  let mulliganBox = (() => {
    if (props.playerData.player_data.status === "mulligan") return playerMulliganInformationBox(props)
    else return playerMulliganWaitingBox()
  })

  return html`
  <div id="mulliganRegion" key="mulligan-region"
    className="absolute z-50 flex flex-col items-center content-center justify-center p-4 text-center transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2 h-72"
    data-gameboard-animations-target="mulliganRegion">
    ${mulliganBox()}
  
    <section id="mulligan-cards" className="flex flex-row justify-center w-full gap-x-2">
      ${props.playerData.cards.in_hand.map((card) => html`
      <${StandardCard} id=${card.id} key=${card.id} cardConstant=${card.cardConstant} health=${card.health}
        attack=${card.attack} health_cap=${card.health_cap} additionalClasses="relative z-50" keywords=${card.keywords}
        cost=${card.cost} ref=${ref} draggable=${false} type=${card.type} />`)}
    </section>
  </div>`;
});

export default MulliganPopUp;

/**
 


    ${cards.map((card) => html`
    <${StandardCard} id=${card.id} key=${card.id} cardConstant=${card.cardConstant} health=${card.health}
      attack=${card.attack} health_cap=${card.health_cap} dataset=${cardInHandDataAttributes(card)}
      additionalClasses=${cardInHandClassList} keywords=${card.keywords} cost=${card.cost} ref=${ref} draggable=${true} />
    `)}
 */