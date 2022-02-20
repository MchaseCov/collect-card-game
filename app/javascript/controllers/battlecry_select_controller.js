import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="battlecry-select"
export default class extends Controller {
  static targets = ['playableBattlecryCard', 'inPlayBattlecry', 'validBattlecry', 'enemyMinionActor', 'opposingPlayer', 'friendlyPlayer'];

  inPlayBattlecryTargetConnected(element) {
    this.addGreyscaleToIneligableTargets();
    element.classList.remove('hover:z-10', 'hover:bottom-8', 'hover:scale-125');
    element.classList.add('ring', 'ring-red-600')
  }

  validBattlecryTargetConnected(element) {
    element.classList.add('filter-none', 'ring', 'ring-orange-400');
  }

  addGreyscaleToIneligableTargets() {
    if (this.enemyMinionActorTargets.length > 0) {
      this.enemyMinionActorTargets.forEach((el) => { el.classList.add('grayscale'); });
    }
    if (this.friendlyCardInBattleTargets.length > 0) {
      this.friendlyCardInBattleTargets.forEach((el) => { el.classList.add('grayscale'); });
    }
    this.opposingPlayerTarget.classList.add('grayscale');
    this.friendlyPlayerTarget.classList.add('grayscale');
  }

  cancelPlay(){
    location.reload();
  }

  // Don't want this controller to begin doing anything until the base partyplay controller is fully loaded, so
  // create custom "initialize" method to run start-of-class code after partyplay controller is ready
  loadController({ detail: { spaces, friendlyCards } }) {
    this.playableSpaces = spaces;
    this.friendlyCardInBattleTargets = friendlyCards;
    this.playableBattlecryCardTargets.forEach((el) => {
      this.evaluateBattlecry(el);
      el.validTargets = this.filteredTargets;
    });
  }

  evaluateBattlecry(element) {
    const targets = this.evaluateTargets(element);
    let result = false;
    if (targets) {
      const targetCompare = element.dataset.compare.split(',');
      const validTargets = this.filterTargets(targets, targetCompare);
      if (validTargets.length > 0) {
        this.filteredTargets = validTargets;
        result = true;
      }
    }
    return result;
  }

  evaluateTargets(element) {
    switch (element.dataset.target) {
      case 'friendly_battle':
        return this.friendlyCardInBattleTargets;
      default:
        return false;
    }
  }

  filterTargets(targets, targetCompare) {
    const validTargets = [];
    targets.forEach((el) => {
      if (el.dataset[targetCompare[0]] === targetCompare[1]) {
        validTargets.push(el);
      }
    });
    return validTargets;
  }

  selectTarget(event) {
    this.partyPlayController.translateTo(this.inPlayBattlecryTarget, event.target)
    fetch(`/games/${this.element.dataset.game}/play_card`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        card_id: this.inPlayBattlecryTarget.dataset.id,
        position: this.inPlayBattlecryTarget.dataset.chosenPosition,
        battlecry_target: event.target.dataset.id,
      }),
    });
  }

  get partyPlayController() {
    return this.application.getControllerForElementAndIdentifier(this.element, "drag-party-play")
  }
}
