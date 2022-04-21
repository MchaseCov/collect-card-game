import { forwardRef } from "react";
import html from '../htm_create_element';


const endTurnButton = forwardRef((props, ref) => {
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
  return html`<section id="turn-button" key="turnButton" className="absolute top-1/2 bottom 1/2">
    ${props.gameCurrentTurn ? 'Player 1' : 'Player 2'}'s Turn!
    <form className="button_to" method="post" action="/games/${props.gameId}/end_turn">
      <button ref=${ref} className="px-4 py-2 font-bold text-white bg-blue-500 rounded disabled:bg-gray-200" type="submit" disabled=${props.disabled}>End Turn</button>
      <input type="hidden" name="authenticity_token" value=${csrf} /> 
    </form>
  </section>`

})

export default endTurnButton