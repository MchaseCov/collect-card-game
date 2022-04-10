const gameBoard = document.getElementById('main-game-board');
export default function createMainGameBoard(data) {
  gameBoard.dataset.game = data.id;
  gameBoard.dataset.gameboardAnimationsStatusValue = data.status;
  gameBoard.dataset.gameboardAnimationsTurnValue = data.turn_time;
}
