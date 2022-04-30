import { createRoot } from 'react-dom/client';

import html from '../components/htm_create_element';
import GameContainer from '../components/game/game_container';
import mulliganContainer from '../components/game/mulligan_container';
import { cardConstantIndexedDb } from '../indexeddb/card_constants';
import { keywordIndexedDb } from '../indexeddb/keywords';
import { archetypeIndexedDb } from '../indexeddb/archetypes';
import { raceIndexedDb } from '../indexeddb/races';

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
    filteredData = await this.assignRaces(filteredData);
    return filteredData;
  }

  async assignRaces(updatedGameData) {
    const raceDb = new raceIndexedDb();
    await raceDb.initialize();
    [updatedGameData.player, updatedGameData.opponent].forEach(async (player) => {
      player.player_data.race = await raceDb.itemById(player.player_data.race_id);
    });
    return updatedGameData;
  }

  async fetchConstantsFromIndexDb(range) {
    const cardConstantDb = new cardConstantIndexedDb();
    await cardConstantDb.initialize();
    return await cardConstantDb.itemsInRange(...range);
  }

  async fetchKeywordsFromIndexDb(range) {
    const keywordDb = new keywordIndexedDb();
    await keywordDb.initialize();
    return await keywordDb.itemsInRange(...range, 'card_constant_id');
  }

  async assignArchetypeColorsToConstants(updatedGameData) {
    const archDb = new archetypeIndexedDb();
    await archDb.initialize();
    const arches = await archDb.allItems();
    [updatedGameData.player.player_data, updatedGameData.opponent.player_data].forEach((player) => player.archetype = arches.find((a) => a.id === player.archetype_id));

    this.cardConstants.map((cc) => cc.archetypeColor = arches.find((a) => a.id === cc.archetype_id).color);
  }

  async filterKeywordsAndConstants(updatedGameData) {
    const cardsSetsToMatch = [updatedGameData.player.cards.in_hand, updatedGameData.player.cards.in_battlefield, updatedGameData.opponent.cards.in_battlefield, [updatedGameData.lastPlayedCard]];

    const range = this.findMinAndMaxCardConstantId(cardsSetsToMatch);
    this.cardConstants = await this.fetchConstantsFromIndexDb(range);
    this.cardKeywords = await this.fetchKeywordsFromIndexDb(range);
    await this.assignArchetypeColorsToConstants(updatedGameData);
    cardsSetsToMatch.filter((item) => item).forEach((cardSet) => cardSet.forEach(((card) => this.matchKeywordsAndConstantsToCard(card))));
    if (updatedGameData.lastPlayedCard) this.matchKeywordsAndConstantsToCard(updatedGameData.lastPlayedCard);
    return updatedGameData;
  }

  matchKeywordsAndConstantsToCard(card) {
    if (!card) return;
    card.cardConstant = this.cardConstants.find((c) => c.id === card.card_constant_id);
    card.keywords = this.cardKeywords.filter((c) => c.card_constant_id === card.card_constant_id);
  }

  provideDataToDragController(gameData) {
    if (typeof document['gameplay-drag'] !== 'undefined') document['gameplay-drag'].loadControllerFromData(gameData);
    setTimeout(this.provideDataToDragController, 250, gameData);
  }

  findMinAndMaxCardConstantId = (cardsSetsToMatch) => {
    const cardsToCompare = cardsSetsToMatch.flat().filter(Boolean);
    const smallest = cardsToCompare.reduce((res, obj) => ((obj.card_constant_id < res.card_constant_id) ? obj : res));
    const largest = cardsToCompare.reduce((res, obj) => ((obj.card_constant_id > res.card_constant_id) ? obj : res));
    return ([smallest.card_constant_id, largest.card_constant_id]);
  };
}
