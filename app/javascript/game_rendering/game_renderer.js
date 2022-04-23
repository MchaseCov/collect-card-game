import { createRoot } from 'react-dom/client';

import html from '../components/htm_create_element';
import GameContainer from '../components/game/game_container';
import mulliganContainer from '../components/game/mulligan_container';
import { cardConstantIndexedDb } from '../indexeddb/card_constants';

const gameContainer = document.getElementById('game-container');

function createGameRoot() {
  if (gameContainer) return createRoot(gameContainer);
}
const gameRoot = createGameRoot();

export class GameRenderer {
  async updateGameData(updatedGameData) {
    this.gameData = await this.filterAndOrganizeData(updatedGameData);
  }

  async renderGameWindow(animationData) {
    switch (this.gameData.game.status) {
      case 'mulligan':
        const mulliganElement = html`<${mulliganContainer} gameData=${this.gameData} animationData=${animationData} />`;
        gameRoot.render(mulliganElement);
        break;
      default:
        const gameElement = html`<${GameContainer} gameData=${this.gameData} animationData=${animationData} />`;
        gameRoot.render(gameElement);
        this.provideDataToDragController(this.gameData);
    }
  }

  async filterAndOrganizeData(updatedGameData) {
    let filteredData = await this.filterKeywordsAndConstants(updatedGameData);
    filteredData = this.purgeExtraData(updatedGameData);
    return filteredData;
  }

  async fetchConstantsFromIndexDb(cardsSetsToMatch) {
    const range = this.findMinAndMaxCardConstantId(cardsSetsToMatch);
    const cardConstantDb = new cardConstantIndexedDb();
    await cardConstantDb.initialize();
    return await cardConstantDb.itemsInRange(...range);
  }

  async filterKeywordsAndConstants(updatedGameData) {
    const cardsSetsToMatch = [updatedGameData.player.cards.in_hand, updatedGameData.player.cards.in_battlefield, updatedGameData.opponent.cards.in_battlefield];
    this.cardKeywords = updatedGameData.card_keywords;
    this.cardConstants = await this.fetchConstantsFromIndexDb(cardsSetsToMatch);
    cardsSetsToMatch.filter((item) => item).forEach((cardSet) => cardSet.forEach(((card) => this.matchKeywordsAndConstantsToCard(card))));
    if (updatedGameData.lastPlayedCard) this.matchKeywordsAndConstantsToCard(updatedGameData.lastPlayedCard);
    return updatedGameData;
  }

  matchKeywordsAndConstantsToCard(card) {
    card.cardConstant = this.cardConstants.find((c) => c.id === card.card_constant_id);
    card.keywords = this.cardKeywords.filter((c) => c.card_constant_id === card.card_constant_id);
  }

  purgeExtraData(updatedGameData) {
    delete updatedGameData.card_keywords;
    delete updatedGameData.card_constant_data;
    return updatedGameData;
  }

  provideDataToDragController(gameData) {
    if (typeof document['gameplay-drag'] !== 'undefined') document['gameplay-drag'].loadControllerFromData(gameData);
    setTimeout(this.provideDataToDragController, 250, gameData);
  }

  findMinAndMaxCardConstantId = (cardsSetsToMatch) => {
    const cardsToCompare = cardsSetsToMatch.flat();
    const smallest = cardsToCompare.flat().reduce((res, obj) => ((obj.card_constant_id < res.card_constant_id) ? obj : res));
    const largest = cardsToCompare.flat().reduce((res, obj) => ((obj.card_constant_id > res.card_constant_id) ? obj : res));
    return ([smallest.card_constant_id, largest.card_constant_id]);
  };
}
