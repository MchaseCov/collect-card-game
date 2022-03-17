export default class TargetableActions {
  constructor(controller, element, targetData) {
    this.controller = controller;
    this.element = element;
    this.targetData = targetData;
    this.updateBoardstate();
  }

  updateBoardstate() {
    this.element.dataset.action += ` click->${this.controller}#cancelPlay`;
    this.targetData.forEach((id) => this.markAsValidTarget(document.querySelector(`[data-id="${id}"]`)));
    this.element.classList.remove('hover:z-10', 'hover:bottom-8', 'hover:scale-125', 'ring-lime-500');
    this.element.classList.add('ring', 'ring-red-600', 'filter-none');
  }

  markAsValidTarget(element) {
    element.classList.add('filter-none');
    element.setAttribute('data-action', ` click->${this.controller}#selectTarget`); // Intentionally erases old data to prevent strange action ordering by dragging card in this stage
  }

  addGreyscaleToIneligableTargets(targets) {
    targets.forEach((targetGroup) => {
      if (targetGroup.length > 0) {
        targetGroup.forEach((el) => el.classList.add('grayscale'));
      }
    });
  }
}
