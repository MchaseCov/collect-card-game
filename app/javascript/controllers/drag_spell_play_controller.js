// import { Controller } from '@hotwired/stimulus';
import { PlayParentController } from './play_parent_controller';

// Connects to data-controller="drag-spell-play"
export default class extends PlayParentController {
  static targets = ['playableCard', 'battlefield'];


  initialize() {
    super.initialize(this.playableCardTargets);
    this.keepBoardSpaceWide = true
  }

  drop(event) {
    event.stopPropagation();
    event.target.classList.remove('bg-lime-500');
    // NEED TO MAKE A SPELL CONTROLLER
    this.dragSrcEl.dataset.hasTargets ? this.dragSrcEl.setAttribute('data-battlecry-select-target', 'inPlayBattlecry') : this.postToPlayCardPath('party');
  }
}
