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
    this.initialDecorationAttributes = ['w-8', 'h-52', 'bg-clip-padding', 'px-5', '-mx-2.5', 'bg-lime-500'];
    this.targetDecorationAttributes = ['shadow-2xl', 'shadow-lime-500'];
    this.targetHoverDecorationAttributes = ['ring'];
    this.startGameDecoration();
  }

  searchForValidTargets(targetData) {
    return targetData.map((id) => (this.recievesPlayerInputTargets.find((el) => +el.dataset.id === id)));
  }

  startGameDecoration() {
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.add(...this.initialDecorationAttributes));
    this.target.classList.add(...this.targetDecorationAttributes);
  }

  endGameDecoration() {
    this.removeBoardspaceHoverDecoration();
    this.recievesPlayToBoardTargets.forEach((el) => el.classList.remove(...this.initialDecorationAttributes));
    this.target.classList.remove(...this.targetDecorationAttributes);
  }

  createPreviewCard(element) {
    this.previewCard = element.cloneNode(true);
    this.previewCard.innerHTML = this.target.innerHTML;
    this.previewCard.classList = `${this.target.classList} opacity-50`;
    this.previewCard.classList.remove('-ml-10');
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

  addTargetHoverDecoration(element) {
    element.classList.add(...this.targetDecorationAttributes);
  }

  removeTargetHoverDecoration(element) {
    element.classList.remove(...this.targetDecorationAttributes);
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
