import { Controller } from '@hotwired/stimulus';
import BoardPlayHandler from '../board_play_handler';
import TargetByClickHandler from '../target_by_click_handler';
import TargetDataFetcher from '../target_data_fetcher';

// Connects to data-controller="gameplay-drag"
export default class extends Controller {
  static targets = ['playsToBoard', 'takesPlayerInput', 'recievesPlayToBoard', 'recievesPlayerInput'];
  static values = {
    playerCost: Number,
    playerResource: Number,
    currentTurn: Boolean,
    playerTurn: Boolean,
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
    const playsToBoard = this.playsToBoardTargets.includes(event.target)
    const hasTargets = event.target.dataset.targets
    if (playsToBoard) {
      // All cards from hand that play to board, even those with battlecry target effects
      this.handler =  new BoardPlayHandler(this, event)
    } else if (hasTargets) {
      // This could be either a spell from hand OR combat, etc
    }
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.dropEffect = 'move';
    event.dataTransfer.setData('text/html', event.target.innerHTML);
  }

  dragEnter(event) {
    if (event.preventDefault) event.preventDefault();
    if (this.handler.willPlayToBoard) return;
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
    event.stopPropagation();
    if (this.handler.willPlayToBoard) return   
    if (this.playsToBoardTargets.includes(this.handler.target) && this.handler.validDropTargets.includes(event.target)) {
      //this.handler.postPlayerAction(this.handler.currentlyReplacedSpace.dataset.gameplayDragBoardTargetParam, event.target.dataset.id)
  } else {
      console.log('This is NOT something that goes into play, but rather it directly targets X. Either a spell with a target or combat!');
      // Probably want to add a check to see if the initial element was in combat or in hand and then account according to that
    }
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
