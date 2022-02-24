import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="animations"
export default class extends Controller {
  static targets = ['battleAnimationValues', 'fromHandAnimationValues', 'cardDeathAnimationValues', 'battlefield', 'player', 'hand', 'lastPlayed'];

  battleAnimationValuesTargetConnected(element){
    const animationData = element.dataset;
    this.animateBattle(JSON.parse(animationData.attackerValue), JSON.parse(animationData.defenderValue));
  }

  fromHandAnimationValuesTargetConnected(element) {
    const animationData = element.dataset;
    if (this.lastPlayedCard) {this.lastPlayedCard.classList.remove('last-played-card')}
    this.animateCardPlay(this.setCardAnimationValues(animationData));
  }

  cardDeathAnimationValuesTargetConnected(element) {
    console.log(element.dataset.deadCards)
    const dyingCardIds = JSON.parse(element.dataset.deadCards);
    const dyingCards = dyingCardIds.map((id) => this.battlefieldTarget.querySelector(`[data-id="${id}"]`))
    dyingCards.forEach((card) => this.killCard(card))
  }

  lastPlayedTargetConnected(element){
    this.lastPlayedCard = this.battlefieldTarget.querySelector(`[data-id="${element.dataset.animationOf}"]`)
    this.lastPlayedCard.classList.add('last-played-card')
  }

  // BATTLE ANIMATION FUNCTIONS

  animateBattle(attackerObj, defenderObj) {
    const attacker = this.getActorFromObject(attackerObj);
    const defender = this.getActorFromObject(defenderObj);
    const translation = this.findDifferenceInPositions(attacker, defender);
    this.translateToAndFrom(attacker, translation);
  }

  getActorFromObject(object) {
    return this.getActorByTypeAndID(Object.keys(object)[0], object[Object.keys(object)[0]]);
  }

  getActorByTypeAndID(type, id) {
    switch (type) {
      case 'PartyCardGamestate':
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
    let translation = this.findDifferenceInPositions(playedCardValues.cardElement, playedCardValues.targetPosition);
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
      positionNumber: animationData.targetId
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

  killCard(card){
    card.classList.add('grayscale', 'dying-card', 'overflow-hidden');
    card.nextElementSibling.style.width = "0px";
    card.style.width = "0px";
    card.style.margin = "0px";
  }

}
