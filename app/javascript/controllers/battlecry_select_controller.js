import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="battlecry-select"
export default class extends Controller {
  static targets = ['choosableBattlecry', 'inPlayBattlecry', 'enemyMinionActor', 'opposingPlayer', 'friendlyPlayer'];

  inPlayBattlecryTargetConnected(element) {
    element.dataset.action += ' click->battlecry-select#cancelPlay';
    this.battlecriesWithTarget[element.dataset.battlecry].forEach((id) => this.markAsValidTarget(document.querySelector(`[data-id="${id}"]`)));
    this.addGreyscaleToIneligableTargets();
    element.classList.remove('hover:z-10', 'hover:bottom-8', 'hover:scale-125', 'ring-lime-500');
    element.classList.add('ring', 'ring-red-600');
  }

  markAsValidTarget(element) {
    element.classList.add('filter-none');
    element.setAttribute('data-action', 'click->battlecry-select#selectTarget'); // Intentionally erases old data to prevent strange action ordering by dragging card in this stage
  }

  addGreyscaleToIneligableTargets() {
    const targetGroups = [this.enemyMinionActorTargets, this.partyPlayController.friendlyCardInBattleTargets, this.partyPlayController.playableCardTargets, this.opposingPlayerTargets, this.friendlyPlayerTargets];
    targetGroups.forEach((targetGroup) => {
      if (targetGroup.length > 0) {
        targetGroup.forEach((el) => el.classList.add('grayscale'));
      }
    });
  }

  cancelPlay() {
    location.reload();
  }

  initialize() {
    const localStorageValid = (+localStorage.getItem('battlecryDataTimestamp') === + new Date(this.element.dataset.updated))
    this.battlecriesWithTarget = (localStorageValid ? JSON.parse(localStorage.getItem('battlecryData')) : {})
  }

  async connect() {
    if (!Object.keys(this.battlecriesWithTarget).length === 0) return; // Stop if pulled local storage data
    await new Promise((r) => setTimeout(r, 200)); // Gives time for the partyPlayController to always be loaded first, no race condition
    if (!this.partyPlayController.playerCanAct) return; // Stop if not the player's turn
    const battlecries = [];
    this.choosableBattlecryTargets.forEach((e) => !battlecries.includes(e.dataset.battlecry) && battlecries.push(e.dataset.battlecry));
    await Promise.all(battlecries.map((id) => this.requestTargets(id)))
    localStorage.setItem('battlecryData', JSON.stringify(this.battlecriesWithTarget)) // Stores battlecry target data in localstorage to reduce request spam
    localStorage.setItem('battlecryDataTimestamp', + new Date(this.element.dataset.updated)) // Timestamp for comparison
  }

  async requestTargets(id) {
    const response = await fetch(`/battlecries/${id}/targets?game=${this.element.dataset.game}`, {
      method: 'GET',
      credentials: 'same-origin',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
    });
    if (response.ok) {
      const json = await response.json();
      if (json.ids.length > 0) {
        this.battlecriesWithTarget[id] = json.ids;
        this.choosableBattlecryTargets.filter((el) => el.dataset.battlecry === id).forEach((el) => el.dataset.hasTargets = true);
      }
    }
  }

  selectTarget(event) {
    this.partyPlayController.postToPlayCardPath(event.target.dataset.id);
  }

  get partyPlayController() {
    return this.application.getControllerForElementAndIdentifier(this.element, 'drag-party-play');
  }
}
