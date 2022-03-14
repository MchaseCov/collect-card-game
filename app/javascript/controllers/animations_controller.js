import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="animations"
export default class extends Controller {
  static targets = ['battleAnimationValues', 'fromHandAnimationValues', 'cardDeathAnimationValues', 'drawCardAnimationValues', 'drawnCard', 'battlefield', 'player', 'hand', 'lastPlayed', 'mulliganEnding'];

  // RELATED FUNCTIONS ARE LISTED IN ORDER OF CONNECTION FUNCTION

  // ANIMATION FOR CARDS MEETING IN BATTLE
  battleAnimationValuesTargetConnected(element) {
    const animationData = element.dataset;
    this.animateBattle(JSON.parse(animationData.attackerValue), JSON.parse(animationData.defenderValue));
    element.remove()
  }

  // ANIMATION FOR CARD MOVING FROM HAND TO BATTLEFIELD & FADING
  fromHandAnimationValuesTargetConnected(element) {
    const animationData = element.dataset;
    if (this.lastPlayedCard) { this.lastPlayedCard.classList.remove('last-played-card'); }
    this.animateCardPlay(this.setCardAnimationValues(animationData));
    element.remove()
  }

  // ANIMATION FOR CARDS DYING AND FADING FROM BATTLE
  cardDeathAnimationValuesTargetConnected(element) {
    const dyingCardIds = JSON.parse(element.dataset.deadCards);
    const dyingCards = dyingCardIds.map((id) => this.battlefieldTarget.querySelector(`[data-id="${id}"]`));
    dyingCards.forEach((card) => this.killCard(card));
    element.remove()
  }

  // ANIMATION FOR CARD BEING DRAWN TO HAND
  drawCardAnimationValuesTargetConnected(element) {
    this.drawCardToHand(this.drawnCardTarget, element.dataset.playerIdentifier)
    element.remove()
  }
  
  // ANIMATION FOR EASING IN A CARD PLAYED TO BOARD
  lastPlayedTargetConnected(element) {
    this.lastPlayedCard = this.battlefieldTarget.querySelector(`[data-id="${element.dataset.animationOf}"]`);
    this.lastPlayedCard.classList.add('last-played-card');
  }

  // ANIMATIONS FOR END OF MULLIGAN TRANSITION
  mulliganEndingTargetConnected(element){
    this.animateEndOfMulligan(this.setMulliganAnimationData(element))
  }

  // BATTLE ANIMATION FUNCTIONS

  animateBattle(attackerObj, defenderObj) {
    const attacker = this.getActorFromObject(attackerObj);
    const defender = this.getActorFromObject(defenderObj);
    const translation = this.findDifferenceInPositions(attacker, defender);
    this.translateToAndFrom(attacker, translation);
    this.createDamageIndicators(attacker, defender)
  }
  
  async createDamageIndicators(attacker, defender){
    const pairs = [[defender, (+attacker.querySelector('#attack').innerText)],[attacker,(+defender.querySelector('#attack').innerText)]]
    await new Promise((r) => setTimeout(r, 200)); // Not quite enough time to use an .onAnimatonEnd listener
    pairs.forEach((pair)=> this.indicateDamageTaken(pair));
  }

  indicateDamageTaken(pair){
    if(pair[1] <= 0) return;
    const indicator = document.createElement("div");
    indicator.className = "absolute flex items-center justify-center text-5xl text-white top-1/2 left-1/2 burst-8 shake-indicator"
    indicator.innerText = -pair[1]
    pair[0].appendChild(indicator)
    pair[0].classList.add('shake')
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

  animateCardPlay(playedCardValues) {
    const leftCards = this.collectRelatives(playedCardValues.targetPosition, 'previousElementSibling');
    const rightCards = this.collectRelatives(playedCardValues.targetPosition, 'nextElementSibling');
    this.animateCardsOnBoard(leftCards, 'left');
    this.animateCardsOnBoard(rightCards, 'right');
    this.animateCardFromHand(playedCardValues);
  }

  animateCardFromHand(playedCardValues) {
    const translation = this.findDifferenceInPositions(playedCardValues.cardElement, playedCardValues.targetPosition);
    playedCardValues.cardElement.classList.add('card-from-hand');
    playedCardValues.cardElement.style.transform = `translate(${translation.x}px, ${translation.y}px)`;
  }

  animateCardsOnBoard(cards, direction) {
    cards.forEach((e) => {
      e.classList.add(`card-to-${direction}`);
    });
  }

  setCardAnimationValues(animationData) {
    const hand = this.handTargets.find((el) => el.id === `${animationData.playerIdentifier}-cards-hand`);
    const battlefieldOfPlayer = this.battlefieldTarget.querySelector(`#${animationData.playerIdentifier}-cards-battle`);
    return {
      cardElement: hand.querySelector(`[data-id="${animationData.playedCardId}"]`),
      targetPosition: battlefieldOfPlayer.querySelector(`[data-id="${animationData.targetId}"]`),
      positionNumber: animationData.targetId,
    };
  }

  translateTo(actor, translation, timing = 500) {
    actor.animate(
      [{ transform: 'translate(0, 0)' },
        { transform: `translate(${~~translation.x}px, ${~~translation.y}px)` }],
      timing,
    );
  }

  collectRelatives(element, relation) {
    const relatives = [];
    let e = element;
    while (e[relation]) {
      e = e[relation];
      relatives.push(e);
    }
    return relatives;
  }

  // CARD DEATH ANIMATION FUNCTION

  killCard(card) {
    card.classList.add('grayscale', 'dying-card', 'overflow-hidden');
    card.nextElementSibling.style.width = '0px';
    card.style.width = '0px';
    card.style.margin = '0px';
  }

  // CARD DRAW ANIMATION FUNCTION

  drawCardToHand(card, identifier){
    const hand = this.handTargets.find((el) => el.id === `${identifier}-cards-hand`);
    hand.appendChild(card)
    const ytrans = (identifier == "fp" ? -8.6 : 8.6)
    card.style.transform = `translate(33vw, ${ytrans}rem) rotateY(180deg)`;
    card.classList.add('last-drawn');
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
