import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="play-parent"
export class PlayParentController extends Controller { 

  playerCanAct = (this.element.dataset.currentTurn === this.element.dataset.playerTurn);
  playerCostValue = this.element.dataset.cost

  initialize(elements){
    if(!this.playerCanAct || this.boardSpaceTargets.length >= 8) {
      elements.forEach((el)=>this.removeDragFromElement(el))
   } else {
     elements.forEach((el)=>this.evaluatePlaybility(el))
   }
  }

  removeDragFromElement(element) {
    element.dataset.action = element.dataset.action.replace('#dragStart', '#errorFeedback')
    element.classList.remove('ring');
    element.setAttribute('draggable', false);
  }

  evaluatePlaybility(element){
    if(+element.dataset.cost > +this[`player${element.dataset.resource}Value`]) this.removeDragFromElement(element)
  }

  errorFeedback(event) {
    event.target.classList.add('shake');
    event.target.onanimationend = () => event.target.classList.remove('shake');
  }

  // SHARED SIMPLE PLAY FUNCTIONS ====================
  dragStart(event) {
    this.dragSrcEl = event.target;
    event.target.classList.add('shadow-2xl', 'shadow-lime-500');
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/html', event.target.innerHTML);
  }

  dragEnter(event) {
    if (event.preventDefault) event.preventDefault();
  }
  
  dragOver(event) {
    event.target.classList.add('bg-lime-500');
    if (!this.keepBoardSpaceWide) event.target.style.width = '9rem';
    if (event.preventDefault) event.preventDefault();
  }

  dragLeave(event) {
    event.target.classList.remove('bg-lime-500');
    if (!this.keepBoardSpaceWide) event.target.style.width = '0rem';
  }

  dragEnd() {
    if (this.dragSrcEl) {
      this.dragSrcEl.classList.remove('shadow-2xl', 'shadow-lime-500');
    }
  }
}
