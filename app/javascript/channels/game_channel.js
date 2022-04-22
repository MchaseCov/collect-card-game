import consumer from 'channels/consumer';
import { GameRenderer } from '../game_rendering/game_renderer';

export default function connectToGameChannel(gameId, playerId) {
  consumer.subscriptions.create({ channel: 'GameChannel', game: gameId, player: playerId }, {

    connected() {
      this.secondCounter = 0
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
      this.secondCounter += animationData.animationTime || 1
      this.gameRenderer.renderGameWindow(animationData);
      await new Promise((r) => setTimeout(r, (1000 * animationData.animationTime || 1)));
      this.secondCounter -= animationData.animationTime || 1

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
      console.log('waiting for', this.secondCounter)
      await new Promise((r) => setTimeout(r, (1000 * this.secondCounter)));
    },

    async received(data) {
      await this.waitForOngoingAnimations();
      console.log(data)
      this.evaluateStreamPurpose(data);
    },
  });
}
