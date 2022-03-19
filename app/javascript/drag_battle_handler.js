// Handler for cards that play from hand to board, optionally may have a scoped target such as a battlecry.
export default class DragBattleHandler {
  constructor(controller, event) {
    this.target = event.target;
    this.params = event.params;
    this.gameElement = controller.element;
    this.validDropTargets = controller.enemyActorTargets;
    this.cardTooltip = this.target.querySelector(`#card_${this.target.dataset.id}_tooltip`);
    this.gameId = controller.element.dataset.game;
    this.targetableOptionAttributes = ['ring', 'ring-red-600'];
    this.startGameDecoration();
  }

  listenForMouseUp() {
    this.gameElement.dataset.action += ' mouseup->gameplay-drag#drop';
  }

  startGameDecoration() {
    this.listenForMouseUp();
    this.cardTooltip.classList.add('invisible');
    this.target.setAttribute('data-line-drawer-target', 'origin');
    this.validDropTargets.forEach((el) => el.classList.add(...this.targetableOptionAttributes));
  }

  endGameDecoration() {
    this.cardTooltip.classList.remove('invisible');
    this.validDropTargets.forEach((el) => el.classList.remove(...this.targetableOptionAttributes));
    this.target.removeAttribute('data-line-drawer-target');
  }

  cancelPlayerInputPhase() {

  }

  postPlayerAction(targetId, targetType) {
    fetch(`/games/${this.gameId}/combat/${targetType}`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        dragged_id: this.target.dataset.id,
        target_id: targetId,
      }),
    });
  }
}
