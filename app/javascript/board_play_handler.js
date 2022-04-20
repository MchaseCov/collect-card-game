import GameplayHandler from './gameplay_handler';

// Handler for cards that play from hand to board, optionally may have a scoped target such as a battlecry.
const initialDecorationAttributes = ['w-8', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'];
const targetDecorationAttributes = ['ring-sky-600', 'hide-dragging-card', 'hover:invisible'];
const targetableOptionAttributes = ['ring-4', 'ring-amber-400'];
export default class BoardPlayHandler extends GameplayHandler {
  constructor(controller, event) {
    super(controller, event);
    this.recievesPlayToBoardTargets = controller.recievesPlayToBoardTargets; // Board targets
    this.recievesPlayerInputTargets = controller.recievesPlayerInputTargets; // "Targettable" targets (actors in play, players, etc)
    const targetData = controller[`${this.params.targetType}TargetData`]?.[this.target.dataset[this.params.targetType]]; // Searches for target data from controller, which is from local storage
    this.willPlayToBoard = (typeof targetData === 'undefined'); // True if there are no present targets and card will play directly to board
    this.validDropTargets = (this.willPlayToBoard ? this.recievesPlayToBoardTargets : this.searchForValidTargets(targetData)); // Valid drop targets are either found elements matching target data or the board
    this.startGameDecoration();
  }

  // Input IDs of valid targets, returns the associated elements of those IDs
  searchForValidTargets(targetData) {
    return targetData.map((id) => (this.recievesPlayerInputTargets.find((el) => +el.dataset.id === id)));
  }

  setElementClasslistPairs = () => [
    {
      elementList: [this.target.parentElement],
      classList: ['hover:bottom-0'],
      isApplied: true,
    },
    {
      elementList: this.recievesPlayToBoardTargets,
      classList: initialDecorationAttributes,
    },
    {
      elementList: [this.target],
      classList: targetDecorationAttributes,
    },
  ];

  validTargetElementClassPair = () => ({ elementList: this.validDropTargets, classList: targetableOptionAttributes });

  startGameDecoration() {
    this.elementClasslistPairs = this.setElementClasslistPairs();
    if (!this.willPlayToBoard) this.elementClasslistPairs.push(this.validTargetElementClassPair());
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
  }

  endGameDecoration() {
    this.removeBoardspaceHoverDecoration();
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
  }

  createPreviewCard(element) {
    this.previewCard = element.cloneNode(true);
    this.previewCard.innerHTML = this.target.innerHTML;
    this.previewCard.classList = `${this.target.classList} opacity-50`;
    this.previewCard.classList.remove('-ml-10', 'hide-dragging-card', 'hover:invisible', 'hover:z-10', 'hover:bottom-8', 'hover:scale-125', 'ring-lime-500');
    this.previewCard.dataset.action = this.previewCard.dataset.action.replace('dragenter->gameplay-drag#boardspaceDragEnter', '');
  }

  addBoardspaceHoverDecoration(element) {
    this.removeBoardspaceHoverDecoration();
    this.createPreviewCard(element);
    this.currentlyReplacedSpace = element;
    element.replaceWith(this.previewCard);
  }

  removeBoardspaceHoverDecoration() {
    if (this.previewCard === this.currentlyReplacedSpace) return;
    this.previewCard.replaceWith(this.currentlyReplacedSpace);
    this.previewCard.remove();
  }

  setForPlayerInput() {
    this.previewCard.dataset.action += ' click->gameplay-drag#cancelPlayerInputPhase';
    this.validDropTargets.forEach((el) => el.dataset.action += ' click->gameplay-drag#selectTarget');
    this.decorateForPlayerInput();
  }

  cancelPlayerInputPhase() {
    this.endGameDecoration();
    document.body.style.cursor = 'auto';
  }

  decorateForPlayerInput() {
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.remove(...initialDecorationAttributes));
    this.previewCard.classList.remove('opacity-50');
    this.previewCard.setAttribute('data-line-drawer-target', 'origin');
  }

  postParams = (event) => [this.currentlyReplacedSpace.dataset.gameplayDragBoardTargetParam, event.target.dataset.id];

  postPlayerAction(position, target) {
    this.endGameDecoration()
    super.postPlayerAction({ position, target });
  }
}
