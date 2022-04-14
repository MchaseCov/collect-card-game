import decorateGameBoard from './decorate_game_board';
import createOpponentPlayerInfo from './opponent_player_side/op_info';
import createFriendlyPlayerInfo from './friendly_player_side/fp_info';
import createBattlefield from './battlefield/battlefield';

export class GameRenderer {
  constructor(jsonData) {
    const gameData = this.matchConstantsAndKeywords(jsonData);
    decorateGameBoard(gameData.game);
    createOpponentPlayerInfo(gameData.opponent);
    createFriendlyPlayerInfo(gameData.player);
    createBattlefield(gameData.player.cards.in_battlefield, gameData.opponent.cards.in_battlefield);
    this.provideDataToDragController(gameData)
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
    return jsonData;
  }

  provideDataToDragController(gameData){
    if(typeof document['gameplay-drag'] !== "undefined") document['gameplay-drag'].loadControllerFromData(gameData)
    else setTimeout(this.provideDataToDragController, 250, gameData);
  }
}
