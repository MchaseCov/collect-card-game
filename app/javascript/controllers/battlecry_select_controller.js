// import { Controller } from '@hotwired/stimulus';
import { PlayParentController } from './play_parent_controller';
import { TargetableActions } from '../targetable_actions';
// Connects to data-controller="battlecry-select"
export default class extends PlayParentController {
  static targets = ['choosableBattlecry', 'inPlayBattlecry', 'enemyMinionActor', 'opposingPlayer', 'friendlyPlayer'];

  inPlayBattlecryTargetConnected(element) {
    this.dragSrcEl = element;
    const targetActions = new TargetableActions('battlecry-select', this.dragSrcEl, this.battlecriesWithTarget[element.dataset.battlecry]);
    targetActions.addGreyscaleToIneligableTargets([this.enemyMinionActorTargets, this.partyPlayController.friendlyCardInBattleTargets, this.partyPlayController.playableCardTargets, this.opposingPlayerTargets, this.friendlyPlayerTargets]);
  }

  cancelPlay() {
    location.reload();
  }

  initialize() {
    const localStorageValid = (+localStorage.getItem('battlecryDataTimestamp') === +new Date(this.element.dataset.updated));
    this.battlecriesWithTarget = (localStorageValid ? JSON.parse(localStorage.getItem('battlecryData')) : {});
  }

  async connect() {
    if (!Object.keys(this.battlecriesWithTarget).length === 0 || !this.playerCanAct) return; // Stop if pulled local storage data
    const battlecries = [];
    this.choosableBattlecryTargets.forEach((e) => !battlecries.includes(e.dataset.battlecry) && battlecries.push(e.dataset.battlecry));
    await Promise.all(battlecries.map((id) => this.requestTargets(id)));
    localStorage.setItem('battlecryData', JSON.stringify(this.battlecriesWithTarget)); // Stores battlecry target data in localstorage to reduce request spam
    localStorage.setItem('battlecryDataTimestamp', +new Date(this.element.dataset.updated)); // Timestamp for comparison
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
    this.postToPlayCardPath('party', event.target.dataset.id);
  }

  // For accessing values already set in initial paly controller
  get partyPlayController() {
    return this.application.getControllerForElementAndIdentifier(this.element, 'drag-party-play');
  }
}
