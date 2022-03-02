import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag-battle"
export default class extends Controller {
  static targets = ['activeFriendlyActor', 'enemyActor'];

  initialize() {
    this.img = document.createElement('img');
    this.img.src = '/reticle.webp';
  }

  activeFriendlyActorTargetConnected(element) {
    switch (element.dataset.status){
      case 'attacking':
        element.classList.add('z-40', 'board-animatable', 'ring', 'ring-lime-500');
        element.setAttribute('draggable', true);
        break
      case 'currently_defending':
        const attacker = document.querySelector("[data-status='currently_attacking']");
        attacker.classList.add('board-animatable');
        this.translateTo(attacker, element);
        break
      default:
        element.setAttribute('draggable', false);
        break
    }
  }

  dragStart(event) {
    if ((event.target.getAttribute('draggable')) === 'false') {
      this.errorFeedback(event.target);
      event.preventDefault();
    } else {
    // Outline selected card, create drag image, set data for POST
    event.target.classList.add('shadow-2xl', 'shadow-lime-500');
    this.dragSrcEl = event.target;

    event.dataTransfer.setDragImage(this.img, 10, 10);
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
    if (event.target.classList.contains('enemy-card')) {
      // Prevents from accidentally targetting a child element of the card
      event.target.classList.add('shadow-2xl', 'shadow-red-900');
    }
    if (event.preventDefault) {
      event.preventDefault();
    }
  }

  dragLeave(event) {
    event.target.classList.remove('shadow-2xl', 'shadow-red-900');
  }

  drop(event) {
    event.stopPropagation();
    if (event.target.dataset.playerId) {
      this.postPlayerCombat(event.target)
    } else {
      this.postMinionCombat(event.target)
    }
    this.activeFriendlyActorTargets.forEach((el) => el.setAttribute('draggable', false));
  }

  dragEnd() {
    // Remove all shadows from friendly cards and then enemy cards
    this.activeFriendlyActorTargets.forEach((el) => el.classList.remove('shadow-2xl'));
    this.enemyActorTargets.forEach((el) => el.classList.remove('shadow-2xl'));
  }


  errorFeedback(target) {
    target.classList.add('shake');
    setTimeout(() => { target.classList.remove('shake'); }, 500);
  }

  postMinionCombat(target) {
    fetch(`/games/${this.element.dataset.game}/minion_combat`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        dragged_id: this.dragSrcEl.dataset.id,
        target_id: target.dataset.id,
      }),
    });
}
  postPlayerCombat(target) {
      fetch(`/games/${this.element.dataset.game}/player_combat`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify({
          dragged_id: this.dragSrcEl.dataset.id,
          target_id: target.dataset.playerId,
        }),
      });
  }
}
