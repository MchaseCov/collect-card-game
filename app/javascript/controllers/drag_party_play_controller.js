import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag-party-play"
export default class extends Controller {
  static targets = ['playableCard', 'boardSpace'];

  static values = { game: Number, playerCost: Number, gameTurn: Boolean, playerTurn: Boolean };

  initialize() {
    // If there are no cards in play, make the play area very wide
    if (this.boardSpaceTargets.length === 1) {
      this.boardSpaceTarget.style.width = '100%';
    }
    this.playerCanAct = (this.playerTurnValue === this.gameTurnValue)
  }

  playableCardTargetConnected(element) {
    if (element.dataset.cost > this.playerCostValue || this.boardSpaceTargets.length === 8 || !this.playerCanAct) {
      this.removeDragFromElement(element)
    }
  }

  dragStart(event) {
    if ((event.target.getAttribute('draggable')) === 'false') {
      this.errorFeedback(event.target);
      event.preventDefault();
    } else {
    // Outline selected card, set data for POST
      this.boardSpaceTargets.forEach((el) => el.classList.remove('hidden'));

      event.target.classList.add('shadow-2xl', 'shadow-lime-500');
      this.dragSrcEl = event.target;

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
      event.target.style.width = '1.25rem';
    }
  }

  drop(event) {
    event.stopPropagation();

    this.translateTo(this.dragSrcEl, event.target);
    // Wait 0.15 seconds before POSTing for the sake of the animation's playtime
    setTimeout(() => {
      fetch(`/games/${this.gameValue}/play_card`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify({
          card_id: this.dragSrcEl.dataset.id,
          position: event.target.dataset.id,
        }),
      });
    }, 150);
  }

  dragEnd() {
    if (this.dragSrcEl) {
    // Remove all shadows from friendly cards and then enemy cards
      this.dragSrcEl.classList.remove('shadow-2xl', 'shadow-lime-500');
      this.boardSpaceTargets.forEach((el) => el.classList.add('hidden'));
    }
  }

  translateTo(playedCard, target) {
    const playedCardCoords = playedCard.getBoundingClientRect();
    const targetCoords = target.getBoundingClientRect();
    const translation = {
      x: (targetCoords.x - playedCardCoords.x),
      y: (targetCoords.y - playedCardCoords.y),
    };
    playedCard.style.transform = `translate(${translation.x}px, ${translation.y}px)`;
  }

  errorFeedback(target) {
    target.classList.add('shake');
    setTimeout(() => { target.classList.remove('shake'); }, 500);
  }

  removeDragFromElement(element) {
    element.classList.remove('ring');
    element.setAttribute('draggable', false);
  }
}
