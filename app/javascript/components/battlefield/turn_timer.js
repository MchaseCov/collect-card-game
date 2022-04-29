import html from '../htm_create_element';
import { useEffect, useState } from 'react';


const turnTimer = props => {
  const [turnTime, setTime] = useState(Math.round((Date.now() - Date.parse(props.turnTime))/1000))

  let turnTimerRatio = Math.min((turnTime / 120 * 100), 100)
  let ticksOngoing = true
  useEffect(() => {
    setTime(Math.round((Date.now() - Date.parse(props.turnTime))/1000))
    const timerID = setInterval( () => tick(), 1000 );
    return function cleanup() {
      clearInterval(timerID);
    };
 });

 useEffect(()=>{
 turnTimerRatio = Math.min((turnTime / 120 * 100), 100)
   if(turnTime >= 120){
     ticksOngoing = false
     endTurn()
   }
 },[turnTime])

 function tick() {
   if (ticksOngoing) setTime(turnTime+1)
 }


 const endTurn = () => {
  fetch(`/games/${props.gameId}/end_turn_on_timer`, {
    method: 'POST',
    credentials: 'same-origin',
    headers: {
      Accept: 'text/vnd.turbo-stream.html',
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
    }
  });
 }

 const turnTimerStyle = {
  width: `${100 - turnTimerRatio}%`,
};

return html`<div className="absolute top-0 bottom-0 right-0 h-2 my-auto bg-rose-600" style=${turnTimerStyle}/>`
}

export default turnTimer