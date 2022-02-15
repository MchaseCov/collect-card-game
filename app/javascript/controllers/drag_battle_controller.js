import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag-battle"
export default class extends Controller {
  static targets = ['activeMinion', 'enemyMinion', 'attackingMinion', 'defendingMinion'];

  static values = { game: Number };

  initialize() {
    this.img = document.createElement('img');
    this.img.src = '/reticle.webp';
  }

  attackingMinionTargetConnected(element) {
    if (this.hasDefendingMinionTarget) {
      this.translateTo(element, this.defendingMinionTarget);
    }
  }

  defendingMinionTargetConnected(element) {
    if (this.hasAttackingMinionTarget) {
      this.translateTo(this.attackingMinionTarget, element);
    }
  }

  dragStart(event) {
    // Outline selected card, create drag image, set data for POST
    event.target.classList.add('shadow-2xl', 'shadow-lime-500');
    this.dragSrcEl = event.target;

    event.dataTransfer.setDragImage(this.img, 10, 10);
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/html', event.target.innerHTML);
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
    this.translateTo(this.dragSrcEl, event.target);
    // Wait 0.1 seconds before POSTing for the sake of the animation's playtmie
    setTimeout(() => {
      fetch(`/games/${this.gameValue}/minion_combat`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify({
          dragged_id: this.dragSrcEl.dataset.id,
          target_id: event.target.dataset.id,
        }),
      });
    }, 100);
  }

  dragEnd() {
    // Remove all shadows from friendly cards and then enemy cards
    this.activeMinionTargets.forEach((el) => el.classList.remove('shadow-2xl'));
    this.enemyMinionTargets.forEach((el) => el.classList.remove('shadow-2xl'));
  }

  translateTo(attacker, target) {
    const attackerCoords = attacker.getBoundingClientRect();
    const targetCoords = target.getBoundingClientRect();
    const translation = {
      x: (targetCoords.x - attackerCoords.x) * 0.75,
      y: (targetCoords.y - attackerCoords.y) * 0.75,
    };
    attacker.style.transform = `translate(${~~translation.x}px, ${~~translation.y}px)`;
  }
}
