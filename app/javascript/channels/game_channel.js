import consumer from 'channels/consumer';
import { GameRenderer } from '../game_rendering/game_renderer';

let ongoingAnimations = 0;
const delayMulti = 1;

export default function connectToGameChannel(gameId, playerId) {
  consumer.subscriptions.create({ channel: 'GameChannel', game: gameId, player: playerId }, {

    connected() {
      this.gameRenderer = new GameRenderer();
    },

    disconnected() {
    },

    async updateGameWithNewData(gameData) {
      this.gameRenderer.updateGameData(gameData);
      await this.waitForOngoingAnimations();
      this.gameRenderer.renderGameWindow();
    },

    async beginNewAnimation(animationData) {
      ongoingAnimations++;
      this.gameRenderer.renderGameWindow(animationData);
      await new Promise((r) => setTimeout(r, (1000)));
      ongoingAnimations--;
    },

    evaluateStreamPurpose(data) {
      switch (data.streamPurpose) {
        case 'basicUpdate':
          this.updateGameWithNewData(data.gameData);
          break;
        case 'animation':
          if (data.gameData) this.gameRenderer.updateGameData(data.gameData);
          this.beginNewAnimation(data.animationData);
          break;
      }
    },

    async waitForOngoingAnimations() {
      const seconds = (ongoingAnimations * delayMulti);
      await new Promise((r) => setTimeout(r, (1000 * seconds)));
    },

    async received(data) {
      await this.waitForOngoingAnimations();
      console.log(data.gameData)
      this.evaluateStreamPurpose(data);
    },
  });
}
