// Handler for cards that play from hand to board, optionally may have a scoped target such as a battlecry.
export default class BoardPlayHandler {
  constructor(controller, event) {
    this.target = event.target;
    this.params = event.params;
    const targetData = controller[`${this.params.targetType}TargetData`]?.[this.target.dataset[this.params.targetType]];
    this.recievesPlayToBoardTargets = controller.recievesPlayToBoardTargets;
    this.recievesPlayerInputTargets = controller.recievesPlayerInputTargets;
    this.gameId = controller.element.dataset.game;
    this.willPlayToBoard = (typeof targetData === 'undefined');
    this.validDropTargets = (this.willPlayToBoard ? this.recievesPlayToBoardTargets : this.searchForValidTargets(targetData));
    this.initialDecorationAttributes = ['w-8', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5'];
    this.targetDecorationAttributes = ['ring-sky-600', 'hide-dragging-card', 'hover:invisible'];
    this.targetHoverDecorationAttributes = ['ring'];
    this.startGameDecoration();
  }

  searchForValidTargets(targetData) {
    return targetData.map((id) => (this.recievesPlayerInputTargets.find((el) => +el.dataset.id === id)));
  }

  startGameDecoration() {
    this.target.parentElement.classList.remove('hover:bottom-0')
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.add(...this.initialDecorationAttributes));
    this.target.classList.add(...this.targetDecorationAttributes);
    if(!this.willPlayToBoard) {
      this.targetableOptionAttributes = ['ring','ring-4', 'ring-amber-400']
      this.validDropTargets.forEach((el) => el.classList.add(...this.targetableOptionAttributes));
    }
    }

  endGameDecoration() {
    this.removeBoardspaceHoverDecoration();
    this.target.classList.remove(...this.targetDecorationAttributes);
    this.target.parentElement.classList.add('hover:bottom-0')
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.remove(...this.initialDecorationAttributes));
    //this.target.classList.add('hover:z-10','hover:bottom-8', 'hover:scale-125')
    if(!this.willPlayToBoard) {
      this.validDropTargets.forEach((el) => el.classList.remove(...this.targetableOptionAttributes));
    }
  }

  createPreviewCard(element) {
    this.previewCard = element.cloneNode(true);
    this.previewCard.innerHTML = this.target.innerHTML;
    this.previewCard.classList = `${this.target.classList} opacity-50`;
    this.previewCard.classList.remove('-ml-10', 'hide-dragging-card', 'hover:invisible', 'hover:z-10', 'hover:bottom-8', 'hover:scale-125', 'ring-lime-500');
    this.previewCard.dataset.action = this.previewCard.dataset.action.replace('dragenter->gameplay-drag#boardspaceDragEnter', '');
  }

  addBoardspaceHoverDecoration(element) {
    this.removeBoardspaceHoverDecoration();
    this.createPreviewCard(element);
    this.currentlyReplacedSpace = element;
    element.replaceWith(this.previewCard);
  }

  removeBoardspaceHoverDecoration() {
    if (this.previewCard === this.currentlyReplacedSpace) return;
    this.previewCard.replaceWith(this.currentlyReplacedSpace);
    this.previewCard.remove();
  }

  setForPlayerInput(){
    this.previewCard.dataset.action += ' click->gameplay-drag#cancelPlayerInputPhase'
    this.validDropTargets.forEach((el)=> el.dataset.action += ' click->gameplay-drag#selectTarget')
    this.decorateForPlayerInput()
  }

  cancelPlayerInputPhase(){
    //this.lineToCard?.stopDrawing()
    this.endGameDecoration()
    document.body.style.cursor = 'auto'
  }

  decorateForPlayerInput(){
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.remove(...this.initialDecorationAttributes));
    this.previewCard.classList.remove('opacity-50')
    this.previewCard.setAttribute('data-line-drawer-target', 'origin')
  }

  postPlayerAction(position, target) {
    fetch(`/games/${this.gameId}/play_card/${this.params.type}`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        card_id: this.target.dataset.id,
        position,
        target,
      }),
    });
  }
}
