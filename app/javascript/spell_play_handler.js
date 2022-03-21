import GameplayHandler from './gameplay_handler';

const targetDecorationAttributes = ['ring-sky-600', 'hide-dragging-card', 'hover:invisible'];
const battlefield = document.querySelector('#battlefield'); // For specifity

// Handler for spell cards, currently not accounting for target params as this can be added through inheritence or another handler
export default class SpellPlayHandler extends GameplayHandler {
  constructor(controller, event) {
    super(controller, event);
    this.validDropTargets = [battlefield]; // For general compatibility
    this.startGameDecoration();
  }

  setElementClasslistPairs = () => [
    {
      elementList: [this.target.parentElement],
      classList: ['hover:bottom-0'],
      isApplied: true,
    },
    {
      elementList: [...battlefield.children],
      classList: ['pointer-events-none'],
    },
    {
      elementList: [this.target],
      classList: targetDecorationAttributes,
    },
  ];

  startGameDecoration() {
    this.elementClasslistPairs = this.setElementClasslistPairs();
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
    battlefield.setAttribute('data-action', 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver');
  }

  endGameDecoration() {
    this.elementClasslistPairs.forEach((pair) => super.toggleClasses(pair));
    battlefield.classList.remove('bg-lime-200');
    battlefield.removeAttribute('data-action');
  }

  toggleHoverState() {
    battlefield.classList.toggle('bg-lime-200');
  }

  // Return nothing for now as targetting spells are not added yet
  postParams = () => [];

  postPlayerAction(target) {
    super.postPlayerAction({ target });
  }
}
