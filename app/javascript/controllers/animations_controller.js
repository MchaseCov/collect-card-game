import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="animations"
export default class extends Controller {
  static targets = ['attacker', 'defender', 'cardDeathAnimationValues', 'drawnCard', 'battlefield', 'player', 'hand', 'lastPlayed', 'mulliganEnding', 'enterBattle', 'shiftLeft', 'shiftRight', 'fromHand'];


  fromHandTargetConnected(card){
    const id = card.getBoundingClientRect().y > 0 ? 'fp' : 'op'
    const row = document.getElementById(`${id}-cards-battle`)
    const target = row.querySelector(`[data-board-id="${card.dataset.targetPosition || 0}"]`);

    this.animateCardFromHand(card, target)
    this.animateCardInHandGapFill(card)
  }

  animateCardInHandGapFill(card) {
    const cardSiblings = [...card.parentNode.children]
    const position = cardSiblings.indexOf(card)
    cardSiblings.slice(position+1).forEach((card)=> card.classList.add(`card-to-left`))
    cardSiblings.slice(0, position).forEach((card)=> card.classList.add(`card-to-right`))
  }

  enterBattleTargetConnected(card){
    card.classList.add('last-played-card')
    const leftCards = [...document.getElementsByClassName('card-to-left')]
    leftCards.forEach((el)=> el.classList.remove('card-to-left'));
    const rightCards = [...document.getElementsByClassName('card-to-right')]
    rightCards.forEach((el)=> el.classList.remove('card-to-right'))
  }

  shiftLeftTargetConnected(card){
    card.classList.add(`card-to-left`);
  }

  shiftRightTargetConnected(card){
   card.classList.add('card-to-right')
  }


  defenderTargetConnected(defender){
    if (typeof this.attackerTarget === 'undefined') return
    this.animateBattle(this.attackerTarget, defender);
  }

  drawnCardTargetConnected(card){
    this.drawCardToHand(card);
  }

  // CARD DRAW ANIMATION FUNCTION

  drawCardToHand(card){
    const ytrans = (card.getBoundingClientRect().y > 0 ? -9 : 9)
    card.style.transform = `translate(33vw, ${ytrans}rem) rotateY(180deg)`;
    card.classList.add('last-drawn');
    card.onanimationend = () => {
      card.style.removeProperty('transform')
      card.classList.remove('last-drawn')
      card.removeAttribute('data-animations-target')
    }
  }

  // RELATED FUNCTIONS ARE LISTED IN ORDER OF CONNECTION FUNCTION



  // ANIMATION FOR CARDS DYING AND FADING FROM BATTLE
  cardDeathAnimationValuesTargetConnected(element) {
    const dyingCardIds = JSON.parse(element.dataset.deadCards);
    const dyingCards = dyingCardIds.map((id) => this.battlefieldTarget.querySelector(`[data-id="${id}"]`)).filter(Boolean);
    dyingCards.filter(Boolean).forEach((card) => this.killCard(card));
    element.remove()
  }

  
  // ANIMATIONS FOR END OF MULLIGAN TRANSITION
  mulliganEndingTargetConnected(element){
    this.animateEndOfMulligan(this.setMulliganAnimationData(element))
  }

  // BATTLE ANIMATION FUNCTIONS

  animateBattle(attacker, defender) {
    const translation = this.findDifferenceInPositions(attacker, defender);
    this.dyingCards = []
    this.translateToAndFrom(attacker, translation);
    this.createDamageIndicators(attacker, defender);
    attacker.onanimationend = () => this.dyingCards.forEach((card) => this.killCard(card));
  }
  
  async createDamageIndicators(attacker, defender){
    const pairs = [{card: defender, damage: +attacker.querySelector('#attack').innerText}, {card: attacker, damage: +defender.querySelector('#attack').innerText}]
    await new Promise((r) => setTimeout(r, 200)); // Not quite enough time to use an .onAnimatonEnd listener
    pairs.forEach((pair)=> this.indicateDamageTaken(pair));
    pairs.forEach((pair)=> this.updateHealthValues(pair));
  }

  updateHealthValues(pair){
    if(pair.damage <= 0) return;
    const original_hp = +pair.card.querySelector('#health').innerText
    const newHp = (original_hp - pair.damage)
    pair.card.querySelector('#health').innerText = newHp
    if(newHp < original_hp) pair.card.querySelector('#health').classList.add('text-red-500')
    if(newHp <= 0)this.dyingCards.push(pair.card)
  }

  indicateDamageTaken(pair){
    if(pair.damage <= 0) return;
    const indicator = document.createElement("div");
    indicator.className = "absolute flex items-center justify-center text-5xl text-white top-1/2 left-1/2 burst-8 shake-indicator"
    indicator.innerText = -pair.damage
    pair.card.appendChild(indicator)
    pair.card.classList.add('shake')
    indicator.onanimationend = () => indicator.remove()
  }

  getActorFromObject(object) {
    return this.getActorByTypeAndID(Object.keys(object)[0], object[Object.keys(object)[0]]);
  }

  getActorByTypeAndID(type, id) {
    switch (type) {
      case 'PartyCard':
        return this.battlefieldTarget.querySelector(`[data-id="${id}"]`);
      case 'Player':
        return this.playerTargets.find((el) => el.dataset.playerId == id);
      default:
        return false;
    }
  }

  findDifferenceInPositions(attacker, target) {
    attacker.classList.add('z-50', 'board-animatable');
    const attackerCoords = attacker.getBoundingClientRect();
    const targetCoords = target.getBoundingClientRect();
    const translation = {
      x: (targetCoords.x - attackerCoords.x),
      y: (targetCoords.y - attackerCoords.y),
    };
    return translation;
  }

  translateToAndFrom(actor, translation, timing = 500) {
    actor.animate(
      [{ transform: 'translate(0, 0)', easing: 'ease-out' },
        { transform: `translate(${~~(translation.x * 0.75)}px, ${~~(translation.y * 0.75)}px)` },
        { transform: 'translate(0, 0)', easing: 'ease-in' }],
      timing,
    );
  }

  // CARD PLAY ANIMATION FUNCTIONS

  animateCardFromHand(card, target) {
    const translation = this.findDifferenceInPositions(card, target);
    card.classList.add('card-from-hand');
    card.style.transform = `translate(${translation.x}px, ${translation.y}px)`;
  }

  translateTo(actor, translation, timing = 500) {
    actor.animate(
      [{ transform: 'translate(0, 0)' },
        { transform: `translate(${~~translation.x}px, ${~~translation.y}px)` }],
      timing,
    );
  }


  // CARD DEATH ANIMATION FUNCTION

  killCard(card) {
    card.classList.add('grayscale', 'dying-card', 'overflow-hidden');
    card.style.width = '0px';
    card.style.margin = '0px'
  }

  // END OF MULLIGAN TRANSITION FUNCTIONS

  // SET ANIMATION DATA
  setMulliganAnimationData(element){
    const mulliganCardContainer = document.getElementById('mulligan-cards')
    return {
      mulliganContainer:document.getElementById('mulliganRegion'), // Top level mulligan container
      mulliganCardContainer: mulliganCardContainer, // Top level mulligan container
      mulliganCards: [...mulliganCardContainer.children], // Array of displayed card elements
      hand: document.getElementById('fp-cards-hand'), // Friendly player hand
      opponentHand:  document.getElementById('op-cards-hand'), // Opponent player hand
      opponentCardCount: parseInt(element.dataset.opponentCardCount) // Amount of cards that opponent has in hand after mulligan phase ends.
    };
  }

  // CREATE OPP CARDS, CHANGE MULLIGAN CARD PARENTS, TRANSLATE THEM DOWN
  animateEndOfMulligan(data){
    this.createOpponentCardsInHand(data.opponentHand, data.opponentCardCount)
    data.mulliganCards.forEach((card) => {this.moveParentFromMulliganToHand(data.hand, card)})
    this.animateBrightnessAndCardTranslate(data.mulliganContainer, data.mulliganCards)

  }

  // CREATE CARDS IN OPPONENTS HAND EQUAL TO AMOUNT THEY KEPT IN MULLIGAN
  createOpponentCardsInHand(opponentHand, opponentCardCount){
    for(let i = 0; i < opponentCardCount; i++){
      const opponentCard = document.createElement('template')
      opponentCard.innerHTML = '<div class="w-40 h-60 max-h-60 relative text-white border-2 border-black rounded bg-slate-700 inline-block -ml-10 -mt-12"></div>'
      opponentHand.appendChild(opponentCard.content.firstChild)
    }
  }

  // CHANGE PARENT OF CARDS IN MULLIGAN WINDOW TO PLAYER HAND CONTAINER, TRANSLATE UPWARDS TO KEEP RELATIVELY IN PLACE
  // We break them out of the parent because we want to fade the parent's opacity away
  moveParentFromMulliganToHand(hand, card){
    hand.appendChild(card)
    card.style.transform = "translate(0, -50vh)";
    card.classList.add('inline-block', 'mx-1')
  }
    // Change each card's parent, translate them back up to 'not move', add appropriate classes
    // Fade out mulligan container then slide cards down while brightening board
  animateBrightnessAndCardTranslate(mulliganContainer, mulliganCards){
    mulliganContainer.classList.add('fade-out');
      mulliganContainer.onanimationend = () => {
        this.element.classList.remove('brightness-50')
        this.element.animate(
          [{filter: 'brightness(0.5)'}, {filter: 'brightness(1)'}], 2000
        )
        mulliganCards.forEach((e) => {
        e.classList.add("move-card-down")
      })}
  }

}
