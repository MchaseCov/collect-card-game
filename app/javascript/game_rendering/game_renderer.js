import { createRoot } from 'react-dom/client';

import html from '../components/htm_create_element';
import GameContainer from '../components/game/game_container';

const gameContainer = document.getElementById('game-container');
const gameRoot = createRoot(gameContainer);

export class GameRenderer {
  updateGameData(updatedGameData) {
    this.gameData = this.filterAndOrganizeData(updatedGameData);
  }

  renderGameWindow(animationData) {
    const gameElement = html`<${GameContainer} gameData=${this.gameData} animationData=${animationData}/>`;
    gameRoot.render(gameElement);
    this.provideDataToDragController(this.gameData);
  }

  filterAndOrganizeData(updatedGameData) {
    let filteredData = this.filterKeywordsAndConstants(updatedGameData);
    filteredData = this.purgeExtraData(updatedGameData);
    return filteredData;
  }

  filterKeywordsAndConstants(updatedGameData) {
    this.cardConstants = updatedGameData.card_constant_data;
    this.cardKeywords = updatedGameData.card_keywords;
    const cardsSetsToMatch = [updatedGameData.player.cards.in_hand, updatedGameData.player.cards.in_battlefield, updatedGameData.opponent.cards.in_battlefield];
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
    else setTimeout(this.provideDataToDragController, 250, gameData);
  }
}
