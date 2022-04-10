import createOpponentCardsHand from './opponent_card_hand';
import createPlayers from './players';
import createMainGameBoard from './main_game_board';
import createBattlefieldCards from './battlefield_cards';

export class GameRenderer {
  constructor(jsonData) {
    console.log(jsonData);
    createMainGameBoard(jsonData.game);
    createPlayers(jsonData.player.player_data, jsonData.opponent.player_data);
    createOpponentCardsHand(jsonData.opponent.cards.in_hand);
    createBattlefieldCards(jsonData);
  }
}
