// import { Controller } from '@hotwired/stimulus';
import { PlayParentController } from './play_parent_controller';
// Connects to data-controller="drag-party-play"
export default class extends PlayParentController {
  static targets = ['playableCard', 'boardSpace', 'friendlyCardInBattle'];

  initialize() {
    super.initialize(this.playableCardTargets);
    // If there are no cards in play, make the play area very wide
    if (this.boardSpaceTargets.length === 1) {
      this.boardSpaceTarget.style.width = '100%';
      this.keepBoardSpaceWide = true;
    }
  }

  dragStart(event) {
    super.dragStart(event);
    this.boardSpaceTargets.forEach((el) => { el.classList.add('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'); });
  }

  drop(event) {
    event.stopPropagation();
    event.target.style.width = '0rem';
    this.boardSpaceTargets.forEach((el) => el.className = '');
    this.dragSrcEl.dataset.position = event.target.dataset.id;
    this.dragSrcEl.dataset.hasTargets ? this.dragSrcEl.setAttribute('data-battlecry-select-target', 'inPlayBattlecry') : this.postToPlayCardPath('party');
  }

  dragEnd() {
    super.dragEnd();
    this.boardSpaceTargets.forEach((el) => el.classList.remove('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'));
  }
}
