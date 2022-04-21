export default class GameplayHandler {
  constructor(controller, event) {
    this.target = event.target;
    this.params = event.params;
    this.gameId = controller.element.dataset.game; // Game ID for POST
  }

  toggleClasses(pair) {
    pair.alreadyApplied ? this.rmvClasses(pair) : this.addClasses(pair);
  }

  addClasses(pair) {
    pair.elementList.forEach((el) => el.classList.add(...pair.classList));
    pair.alreadyApplied = true;
  }

  rmvClasses(pair) {
    pair.elementList.forEach((el) => el.classList.remove(...pair.classList));
    pair.alreadyApplied = false;
  }

  postPlayerAction(params) {
    fetch(`/games/${this.gameId}/${this.params.action}/${this.params.type}`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        card: this.target.dataset.id,
        target: params.target,
        position: params.position,
      }),
    });
  }
}
