import consumer from 'channels/consumer';
import { GameRenderer } from '../game_rendering/game_renderer';

let ongoingAnimations = 0;
let delayMulti = 1

export default function connectToGameChannel(gameId, playerId) {
  consumer.subscriptions.create({ channel: 'GameChannel', game: gameId, player: playerId }, {

    async evaluateStreamPurpose(data) {
      switch (data.streamPurpose) {
        case 'basicUpdate':
          this.lastRecievedData = data.gameData
          this.gameRenderer = new GameRenderer(this.lastRecievedData);
          await this.waitForOngoingAnimations();
          this.gameRenderer.renderGameWindow()
          break;
        case 'animation':
          await this.waitForOngoingAnimations();
          ongoingAnimations++
          this.gameRenderer.renderGameWindow(data.animationData);
          await new Promise((r) => setTimeout(r, (1000)));
          ongoingAnimations--
          break;
      }
    },

    async waitForOngoingAnimations() {
      const seconds = (ongoingAnimations * delayMulti);
      await new Promise((r) => setTimeout(r, (1000 * seconds)));
    }, 

    connected() {
      console.log('connected');
    },

    disconnected() {
    // Called when the subscription has been terminated by the server
    },

    async received(data) {
      console.log(data);
      this.evaluateStreamPurpose(data);
    },
  });
}
