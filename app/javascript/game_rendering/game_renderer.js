import { createRoot } from 'react-dom/client';

import html from '../components/htm_create_element';
import GameContainer from './game_container';

const gameContainer = document.getElementById('game-container');
const gameRoot = createRoot(gameContainer);

export class GameRenderer {
  updateGameData(newGameData) {
    this.gameData = this.matchConstantsAndKeywords(newGameData);
    this.provideDataToDragController(this.gameData);
  }

  renderGameWindow(animationData) {
    const gameElement = html`<${GameContainer} gameData=${this.gameData} animationData=${animationData}/>`;
    gameRoot.render(gameElement);
  }

  matchConstantsAndKeywords(jsonData) {
    [jsonData.player.cards.in_hand,
      jsonData.player.cards.in_battlefield,
      jsonData.opponent.cards.in_battlefield].forEach((cardSet) => {
      cardSet.forEach((cardData) => {
        cardData.cardConstant = jsonData.card_constant_data.find((c) => c.id === cardData.card_constant_id);
        cardData.keywords = jsonData.card_keywords.filter((c) => c.card_constant_id === cardData.card_constant_id);
      });
    });
    delete jsonData.card_keywords;
    delete jsonData.card_constant_data;
    return jsonData;
  }

  provideDataToDragController(gameData) {
    if (typeof document['gameplay-drag'] !== 'undefined') document['gameplay-drag'].loadControllerFromData(gameData);
    else setTimeout(this.provideDataToDragController, 250, gameData);
  }
}
