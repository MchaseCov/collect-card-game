import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag-party-play"
export default class extends Controller {
  static targets = ['playableCard', 'boardSpace', 'friendlyCardInBattle'];

  static values = {
    playerCost: Number, gameTurn: Boolean, playerTurn: Boolean,
  };

  async initialize() {
    // If there are no cards in play, make the play area very wide
    if (this.boardSpaceTargets.length === 1) {
      this.boardSpaceTarget.style.width = '100%';
    }
    this.playerCanAct = (this.playerTurnValue === this.gameTurnValue);
    // Gives the battlecry select controller .2s to be ready to recieve the dispatch
    await new Promise((r) => setTimeout(r, 200));
    this.dispatch('loadBattlecryController', { detail: { spaces: this.boardSpaceTargets, friendlyCards: this.friendlyCardInBattleTargets } });
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
      this.boardSpaceTargets.forEach((el) =>{ el.classList.add('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5')});
      event.target.classList.add('shadow-2xl', 'shadow-lime-500');
      this.dragSrcEl = event.target;
      this.validTargets = event.target.validTargets;
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.setData('text/html', event.target.innerHTML);
    }
  }

  dragEnter(event) {
    if (event.preventDefault) {
      event.preventDefault();
    }
  }

  dragOver(event) {
    // Makes area lime. If not the "wide default area", make the hover region wide for visual
    event.target.classList.add('bg-lime-500');
    if (this.boardSpaceTargets.length > 1) {
      event.target.style.width = '9rem';
    }
    if (event.preventDefault) {
      event.preventDefault();
    }
  }

  dragLeave(event) {
    // Remove lime color. Return to small size
    event.target.classList.remove('bg-lime-500');
    if (this.boardSpaceTargets.length > 1) {
      event.target.style.width = '0rem';
    }
  }

  drop(event) {
    event.stopPropagation();
    this.boardSpaceTargets.forEach((el) => el.className = "");
    event.target.style.width = '0rem';

    if (this.validTargets != undefined) {
      this.enableBattlecrySelectControllerAttributes(event.target);
    } else {
        this.postToPlayCardPath(event.target);
    }
  }

  dragEnd() {
    if (this.dragSrcEl) {
    // Remove all shadows from friendly cards and then enemy cards
      this.dragSrcEl.classList.remove('shadow-2xl', 'shadow-lime-500');
      this.boardSpaceTargets.forEach((el) => el.classList.remove('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'));
    }
  }

  errorFeedback(target) {
    target.classList.add('shake');
    setTimeout(() => { target.classList.remove('shake'); }, 500);
  }

  removeDragFromElement(element) {
    element.classList.remove('ring');
    element.setAttribute('draggable', false);
  }

  enableBattlecrySelectControllerAttributes(chosenSpace) {
    this.dragSrcEl.setAttribute('data-battlecry-select-target', 'inPlayBattlecry');
    this.dragSrcEl.setAttribute('data-chosen-position', chosenSpace.dataset.id);
    this.dragSrcEl.setAttribute('data-action', 'click->battlecry-select#cancelPlay dragstart->drag-party-play#dragStart dragend->drag-party-play#dragEnd');
    this.validTargets.forEach((el) => {
      el.setAttribute('data-battlecry-select-target', 'validBattlecry');
      el.setAttribute('data-action', 'click->battlecry-select#selectTarget');
    });
  }

  postToPlayCardPath(chosenSpace) {
    fetch(`/games/${this.element.dataset.game}/play_card`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        card_id: this.dragSrcEl.dataset.id,
        position: chosenSpace.dataset.id,
      }),
    });
  }
}
