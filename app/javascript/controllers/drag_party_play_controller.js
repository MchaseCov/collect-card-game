//import { Controller } from '@hotwired/stimulus';
import { PlayParentController } from './play_parent_controller';
// Connects to data-controller="drag-party-play"
export default class extends PlayParentController {
  static targets = ['playableCard', 'boardSpace', 'friendlyCardInBattle'];

  initialize() {
    super.initialize(this.playableCardTargets)
    // If there are no cards in play, make the play area very wide
    if (this.boardSpaceTargets.length === 1) {
      this.boardSpaceTarget.style.width = '100%';
      this.keepBoardSpaceWide = true;
    }
  }

  dragStart(event) {
    super.dragStart(event)
    this.boardSpaceTargets.forEach((el) => { el.classList.add('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'); });
  }

  drop(event) {
    event.stopPropagation();
    event.target.style.width = '0rem';
    this.boardSpaceTargets.forEach((el) => el.className = '');
    this.chosenSpace = event.target;

    this.dragSrcEl.dataset.hasTargets ? this.dragSrcEl.setAttribute('data-battlecry-select-target', 'inPlayBattlecry') : this.postToPlayCardPath();
  }

  dragEnd() {
    super.dragEnd()
    this.boardSpaceTargets.forEach((el) => el.classList.remove('w-5', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'));
  }

  // Target argument is passed from battlecry select controller when applicable
  postToPlayCardPath(target = '') {
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
}
