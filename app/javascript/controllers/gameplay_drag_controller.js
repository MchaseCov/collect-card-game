import { Controller } from '@hotwired/stimulus';
import BoardPlayHandler from '../board_play_handler';
import DragBattleHandler from '../drag_battle_handler';
//import TargetByClickHandler from '../target_by_click_handler';
import TargetDataFetcher from '../target_data_fetcher';

// Connects to data-controller="gameplay-drag"
export default class extends Controller {
  static targets = ['playsToBoard', 'takesPlayerInput', 'recievesPlayToBoard', 'recievesPlayerInput', 'friendlyActor', 'enemyActor'];
  static values = {
    playerCost: Number,
    playerResource: Number,
    currentTurn: Boolean,
    playerTurn: Boolean,
  }

  friendlyActorTargetConnected(element){
    if(element.dataset.status !== "attacking") this.removeDragFromElement(element)
  }

  async initialize() {
    if (this.currentTurnValue !== this.playerTurnValue){
      this.playsToBoardTargets.concat(this.takesPlayerInputTargets).forEach((el)=>{
        this.removeDragFromElement(el)
      })
      return
    }
    this.validatePartyCardsArePlayable();
    await this.prepareBattlecryData();
  }

  dragStart(event) {
    this.handler?.cancelPlayerInputPhase()
    if(this.friendlyActorTargets.includes(event.target)){
      this.handler = new DragBattleHandler(this, event)
      event.preventDefault()
    } else if (this.playsToBoardTargets.includes(event.target)) {
      // All cards from hand that play to board, even those with battlecry target effects
      this.handler =  new BoardPlayHandler(this, event)
    } else if (event.target.dataset.targets) {
      // This could be either a spell from hand OR combat, etc
    }
    console.log(this.handler)
    //event.dataTransfer.effectAllowed = 'move';
    //event.dataTransfer.dropEffect = 'move';
    //event.dataTransfer.setData('text/html', event.target.innerHTML);
  }

  dragEnter(event) {
    if (event.preventDefault) event.preventDefault();
    if ((event.target == this.handler.target)|| this.handler.willPlayToBoard) return;
    this.handler.addTargetHoverDecoration(event.target)
  }
  boardspaceDragEnter(event) {
    if(this.handler.params.type !== "party") return
    this.handler.addBoardspaceHoverDecoration(event.target);
  }

  dragOver(event) {
    if (event.preventDefault) event.preventDefault();
  }

  dragLeave(event) {
    if (this.handler.willPlayToBoard) return;
    this.handler.removeTargetHoverDecoration(event.target)
  }
  boardspaceDragLeave() {
    // Unsure if needed as the current model of decorating hover spaces does not want to trigger here.
  }

  dragEnd() {
    if (this.isInTargetPhase) return this.isInTargetPhase = false 
    this.handler?.endGameDecoration();
  }

  drop(event) {
    this.handler.endGameDecoration();
    if (this.handler.willPlayToBoard) return   
    let postParams
    event.stopPropagation();
    if (this.playsToBoardTargets.includes(this.handler.target) && this.handler.validDropTargets.includes(event.target)) {
      postParams = [this.handler.currentlyReplacedSpace.dataset.gameplayDragBoardTargetParam, event.target.dataset.id]
    } else if (this.handler.validDropTargets.includes(event.target)) {
      postParams = [event.target.dataset.id, event.target.dataset.type]
    }
    if (postParams) this.handler.postPlayerAction(...postParams)
  }

  selectTarget(event) {
    event.stopPropagation();
    this.handler.postPlayerAction(this.handler.currentlyReplacedSpace.dataset.gameplayDragBoardTargetParam, event.target.dataset.id)
    this.handler.cancelPlayerInputPhase()
    this.handler = undefined
  }

  boardspaceDrop(event) {
    if (this.handler.willPlayToBoard) return this.handler.postPlayerAction(event.params.boardTarget)
    if (this.playsToBoardTargets.includes(this.handler.target)){
    this.isInTargetPhase = true
    this.handler.setForPlayerInput()
    }
  }

  cancelPlayerInputPhase(){
    this.handler.cancelPlayerInputPhase()
  }

  async prepareBattlecryData() {
    const localStorageValid = (+localStorage.getItem('battlecryDataTimestamp') === +new Date(this.element.dataset.updated));
    const playableBattlecryTakesInput = this.playsToBoardTargets.filter((e) => this.takesPlayerInputTargets.includes(e));
    if (!localStorageValid) {
      this.battlecryDataFetcher = new TargetDataFetcher(playableBattlecryTakesInput, 'battlecry', this.element);
      await this.battlecryDataFetcher.updateLocalStorageForTargets();
    }
    this.battlecryTargetData = JSON.parse(localStorage.getItem('battlecryData'));
    playableBattlecryTakesInput.forEach((el) => el.dataset.targets = this.battlecryTargetData[el.dataset.battlecry]);
  }

  validatePartyCardsArePlayable() {
    const boardIsFull = (this.recievesPlayToBoardTargets?.length >= 8)
    this.playsToBoardTargets.forEach((element)=> {
      if (boardIsFull || +element.dataset.cost > +this[`player${element.dataset.resource}Value`]) this.removeDragFromElement(element);
    })
  }

  removeDragFromElement(element) {
    element.dataset.action = element.dataset.action.replace('#dragStart', '#errorFeedback');
    element.classList.remove('ring');
    element.setAttribute('draggable', false);
  }

  errorFeedback(event) {
    event.target.classList.add('shake');
    event.target.onanimationend = () => event.target.classList.remove('shake');
  }
}
