import GameplayHandler from './gameplay_handler';

const targetableOptionAttributes = ['ring', 'ring-red-600'];
// Handler for cards that play from hand to board, optionally may have a scoped target such as a battlecry.
export default class DragBattleHandler extends GameplayHandler {
  constructor(controller, event) {
    event.preventDefault();
    super(controller, event);
    this.gameElement = controller.element;
    this.validDropTargets = controller.hasTauntingCardTarget ? controller.tauntingCardTargets : controller.enemyActorTargets;
    this.cardTooltip = this.target.querySelector(`#card_${this.target.dataset.id}_tooltip`);
    this.startGameDecoration();
  }

  listenForMouseUp() {
    this.gameElement.dataset.action += ' mouseup->gameplay-drag#drop';
  }

  setElementClasslistPairs = () => [
    {
      elementList: this.validDropTargets,
      classList: targetableOptionAttributes,
    },
    {
      elementList: [this.cardTooltip],
      classList: ['invisible'],
    },
  ];

  startGameDecoration() {
    this.elementClasslistPairs = this.setElementClasslistPairs();
    this.listenForMouseUp();
    this.target.setAttribute('data-line-drawer-target', 'origin');
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
  }

  endGameDecoration() {
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
    this.target.removeAttribute('data-line-drawer-target');
  }

  cancelPlayerInputPhase = () => {};

  postParams = (event) => [event.target.dataset.id, event.target.dataset.type];

  postPlayerAction(target, targetType) {
    this.params.type = targetType;
    super.postPlayerAction({ target });
  }
}
