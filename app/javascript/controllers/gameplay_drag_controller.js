import { Controller } from '@hotwired/stimulus';
import BoardPlayHandler from '../board_play_handler';
import DragBattleHandler from '../drag_battle_handler';
import TargetDataFetcher from '../target_data_fetcher';
import SpellPlayHandler from '../spell_play_handler';

// Connects to data-controller="gameplay-drag"
export default class extends Controller {
  static targets = ['playsToBoard', 'spellCard', 'takesPlayerInput', 'recievesPlayToBoard', 'recievesPlayerInput', 'friendlyActor', 'enemyActor'];

  static values = {
    playerCost: Number,
    playerResource: Number,
    currentTurn: Boolean,
    playerTurn: Boolean,
  };

  playsToBoardTargetConnected(element){
    this.bindToNode(element, 'createHandler', this.createBoardPlayHandler) 
  }

  friendlyActorTargetConnected(element) {
    if (element.dataset.status !== 'attacking') return this.removeDragFromElement(element);
    this.bindToNode(element, 'createHandler', this.createDragBattleHandler) 
  }

  spellCardTargetConnected(element) {
    if (+element.dataset.cost > +this[`player${element.dataset.resource}Value`]) return this.removeDragFromElement(element);
    if (this.takesPlayerInputTargets.includes(element)) {
      // Stuff about collecting spell targets and doing battlecry-esque things
    } else {
      this.bindToNode(element, 'createHandler', this.createSpellPlayHandler) 
    }
  }

  async initialize() {
    if (this.currentTurnValue !== this.playerTurnValue) {
      this.playsToBoardTargets.concat(this.takesPlayerInputTargets).forEach((el) => {
        this.removeDragFromElement(el);
      });
      return;
    }
    this.validatePartyCardsArePlayable();
    await this.prepareBattlecryData();
  }

  dragStart(event) {
    this.handler = event.target.createHandler ? event.target.createHandler(this, event) : undefined
  }

  dragEnter(event) {
    if (event.preventDefault) event.preventDefault();
    if (this.handler.toggleHoverState ) this.handler.toggleHoverState()
  }

  boardspaceDragEnter(event) {
    if (this.handler.params.type !== 'party') return;
    this.handler.addBoardspaceHoverDecoration(event.target);
  }

  dragOver(event) {
    if (event.preventDefault) event.preventDefault();
  }

  dragEnd() {
    if (this.isInTargetPhase) return this.isInTargetPhase = false;
    this.handler?.endGameDecoration();
  }

  drop(event) {
    this.handler.endGameDecoration();
    if (this.handler.willPlayToBoard || !(this.handler.validDropTargets.includes(event.target))) return;
    event.stopPropagation();
    this.handler.postPlayerAction(...this.handler.postParams(event));
  }

  selectTarget(event) {
    event.stopPropagation();
    this.handler.postPlayerAction(this.handler.currentlyReplacedSpace.dataset.gameplayDragBoardTargetParam, event.target.dataset.id);
    this.handler.cancelPlayerInputPhase();
    this.handler = undefined;
  }

  boardspaceDrop(event) {
    if (this.handler.willPlayToBoard) return this.handler.postPlayerAction(event.params.boardTarget);
    if (this.playsToBoardTargets.includes(this.handler.target)) {
      this.isInTargetPhase = true;
      this.handler.setForPlayerInput();
    }
  }

  cancelPlayerInputPhase() {
    this.handler.cancelPlayerInputPhase();
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
    const boardIsFull = (this.recievesPlayToBoardTargets?.length >= 8);
    this.playsToBoardTargets.forEach((element) => {
      if (boardIsFull || +element.dataset.cost > +this[`player${element.dataset.resource}Value`]) this.removeDragFromElement(element);
    });
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

  bindToNode(node, name, fn) {
    node[name] = fn.bind(node);
  }

  createBoardPlayHandler = function(controller, event) {
    return (new BoardPlayHandler(controller, event))
  }

  createDragBattleHandler = function(controller, event) {
    return (new DragBattleHandler(controller, event))
  }
  createSpellPlayHandler = function(controller, event) {
    return (new SpellPlayHandler(controller, event))
  }
}
