import consumer from "channels/consumer"
import { GameRenderer } from "../game_rendering/game_renderer";


export default function connectToGameChannel(gameId, playerId){
  consumer.subscriptions.create({channel: "GameChannel", game: gameId, player: playerId}, {

  evaluateStreamPurpose(data) {
    switch(data.streamPurpose) {
      case 'basicUpdate':
        console.log("recieved basic update")
        new GameRenderer(data.gameData); 
    }
  },

  connected() {
    console.log("connected")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
    this.evaluateStreamPurpose(data)
  }
});
}
