// Handler for spell cards, currently not accounting for target params as this can be added through inheritence or another handler
export default class SpellPlayHandler {
  constructor(controller, event) {
    this.target = event.target;
    this.params = event.params;
    this.gameId = controller.element.dataset.game;
    this.targetDecorationAttributes = ['ring-sky-600', 'hide-dragging-card', 'hover:invisible'];
    this.battlefield = controller.element.querySelector('#battlefield') // For specifity
    this.validDropTargets = [this.battlefield] // For general compatibility
    this.startGameDecoration();
  }

  startGameDecoration() {
    this.target.parentElement.classList.remove('hover:bottom-0')
    this.target.classList.add(...this.targetDecorationAttributes);
    [...this.battlefield.children].forEach((el)=>el.classList.add('pointer-events-none'))
    this.battlefield.setAttribute('data-action', 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver')
    }

  endGameDecoration() {
    [...this.battlefield.children].forEach((el)=>el.classList.remove('pointer-events-none'))
    this.target.classList.remove(...this.targetDecorationAttributes);
    this.target.parentElement.classList.add('hover:bottom-0')
    this.battlefield.classList.remove('bg-lime-200')
    this.battlefield.removeAttribute("data-action")
  }

  toggleHoverState(){
    this.battlefield.classList.toggle('bg-lime-200')
  }


  postParams(event){
    return []
  }

  postPlayerAction(target) {
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
        target,
      }),
    });
  }
}
