import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag-party-play"
export default class extends Controller {
  static targets = ['playableCard', 'boardSpace', 'friendlyCardInBattle'];

  static values = { playerCost: Number };

  async initialize() {
    // If there are no cards in play, make the play area very wide
    if (this.boardSpaceTargets.length === 1) {
      this.boardSpaceTarget.style.width = '100%';
      this.hasNoCardsOnBoard = true;
    }
    this.playerCanAct = (this.element.dataset.currentTurn === this.element.dataset.playerTurn);
  }

  playableCardTargetConnected(element) {
    if (element.dataset.cost > this.playerCostValue || this.boardSpaceTargets.length === 8 || !this.playerCanAct) {
      this.removeDragFromElement(element);
    }
  }

  dragStart(event) {
    if ((event.target.getAttribute('draggable')) === 'false') {
      this.errorFeedback(event.target);
      event.preventDefault();
    } else {
      this.dragSrcEl = event.target;
      this.boardSpaceTargets.forEach((el) => { el.classList.add('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'); });
      event.target.classList.add('shadow-2xl', 'shadow-lime-500');
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.setData('text/html', event.target.innerHTML);
    }
  }

  dragEnter(event) {
    if (event.preventDefault) event.preventDefault();
  }

  dragOver(event) {
    // Makes area lime. If not the "wide default area", make the hover region wide for visual
    event.target.classList.add('bg-lime-500');
    if (!this.hasNoCardsOnBoard) event.target.style.width = '9rem';
    if (event.preventDefault) event.preventDefault();
  }

  dragLeave(event) {
    // Remove lime color. Return to small size
    event.target.classList.remove('bg-lime-500');
    if (!this.hasNoCardsOnBoard) event.target.style.width = '0rem';
  }

  drop(event) {
    event.stopPropagation();
    event.target.style.width = '0rem';
    this.boardSpaceTargets.forEach((el) => el.className = '');
    this.chosenSpace = event.target;

    this.dragSrcEl.dataset.hasTargets ? this.dragSrcEl.setAttribute('data-battlecry-select-target', 'inPlayBattlecry') : this.postToPlayCardPath();
  }

  dragEnd() {
    // Remove all shadows from friendly cards and then enemy cards
    if (this.dragSrcEl) {
      this.dragSrcEl.classList.remove('shadow-2xl', 'shadow-lime-500');
      this.boardSpaceTargets.forEach((el) => el.classList.remove('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'));
    }
  }

  errorFeedback(target) {
    target.classList.add('shake');
    target.onanimationend = () => target.classList.remove('shake');
  }

  removeDragFromElement(element) {
    element.classList.remove('ring');
    element.setAttribute('draggable', false);
  }

  // Target argument is passed from battlecry select controller when applicable
  postToPlayCardPath(target = false) {
    fetch(`/games/${this.element.dataset.game}/play_card/party`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        card_id: this.dragSrcEl.dataset.id,
        position: this.chosenSpace.dataset.id,
        battlecry_target: target,
      }),
    });
  }

  get battlecrySelectController() {
    return this.application.getControllerForElementAndIdentifier(this.element, 'battlecry-select');
  }
}
