import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="animations"
export default class extends Controller {
  static targets = ['attacker', 'defender', 'drawnCard', 'player', 'hand', 'lastPlayed', 'enterBattle', 'shiftLeft', 'shiftRight', 'fromHand', 'fallbackForEndShift', 'endMulliganPhase'];

  // Generic translation functions.

  findDifferenceInPositions(movingActor, target) {
    const moverCoords = movingActor.getBoundingClientRect();
    const targetCoords = target.getBoundingClientRect();
    const translation = {
      x: (targetCoords.x - moverCoords.x),
      y: (targetCoords.y - moverCoords.y),
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

  translateTo(actor, translation, timing = 500) {
    actor.animate(
      [{ transform: 'translate(0, 0)' },
        { transform: `translate(${~~translation.x}px, ${~~translation.y}px)` }],
      timing,
    );
  }

  // Animations for one actor entity attacking another, such as a card translating to another card and making an attack.
  // Targets involved: Attacker, Defender
  // Triggering Target: Defender

  // Trigger
  defenderTargetConnected(defender) {
    if (typeof this.attackerTarget === 'undefined') return;
    this.animateBattle(this.attackerTarget, defender);
  }

  animateBattle(attacker, defender) {
    const translation = this.findDifferenceInPositions(attacker, defender);
    this.dyingCards = [];
    attacker.classList.add('z-50', 'board-animatable');
    this.translateToAndFrom(attacker, translation);
    this.createDamageIndicators(attacker, defender);
    attacker.classList.remove('z-50', 'board-animatable');
    attacker.removeAttribute('data-animations-target');
    defender.removeAttribute('data-animations-target');
    this.dyingCards.forEach((card) => this.killCard(card));
  }

  async createDamageIndicators(attacker, defender) {
    const pairs = [{ card: defender, damage: +attacker.querySelector('#attack').innerText }, { card: attacker, damage: +defender.querySelector('#attack').innerText }];
    await new Promise((r) => setTimeout(r, 200)); // Not quite enough time to use an .onAnimatonEnd listener
    pairs.forEach((pair) => this.indicateDamageTaken(pair));
    pairs.forEach((pair) => this.updateHealthValues(pair));
  }

  updateHealthValues(pair) {
    if (pair.damage <= 0) return;
    const original_hp = +pair.card.querySelector('#health').innerText;
    const newHp = (original_hp - pair.damage);
    pair.card.querySelector('#health').innerText = newHp;
    if (newHp < original_hp) pair.card.querySelector('#health').classList.add('text-red-500');
    if (newHp <= 0) this.dyingCards.push(pair.card);
  }

  indicateDamageTaken(pair) {
    if (pair.damage <= 0) return;
    const indicator = document.createElement('div');
    indicator.className = 'absolute flex items-center justify-center text-5xl text-white top-1/2 left-1/2 burst-8 shake-indicator';
    indicator.innerText = -pair.damage;
    pair.card.appendChild(indicator);
    pair.card.classList.add('shake');
    indicator.onanimationend = () => { indicator.remove(); pair.card.classList.remove('shake'); };
  }

  killCard(card) {
    card.classList.add('grayscale', 'dying-card', 'overflow-hidden');
    card.style.width = '0px';
    card.style.margin = '0px';
  }

  // Animations for a player drawing a card.
  // Triggering Target:  drawnCard

  drawnCardTargetConnected(card) {
    this.drawCardToHand(card);
  }

  drawCardToHand(card) {
    const ytrans = (card.getBoundingClientRect().y > 0 ? -9 : 9);
    card.style.transform = `translate(33vw, ${ytrans}rem) rotateY(180deg)`;
    card.classList.add('last-drawn');
    card.onanimationend = () => {
      card.style.removeProperty('transform');
      card.classList.remove('last-drawn');
      card.removeAttribute('data-animations-target');
    };
  }

  // Animations for a card exiting hand to enter play
  // Triggering Target: fromHand

  fromHandTargetConnected(card) {
    const id = card.getBoundingClientRect().y > 0 ? 'fp' : 'op';
    const row = document.getElementById(`${id}-cards-battle`);
    const target = row.querySelector(`[data-board-id="${card.dataset.targetPosition || 0}"]`);
    this.animateCardFromHand(card, target);
    this.animateCardInHandGapFill(card);
  }

  animateCardFromHand(card, target) {
    card.classList.add('z-50', 'board-animatable');
    const translation = this.findDifferenceInPositions(card, target);
    card.classList.add('card-from-hand');
    card.style.transform = `translate(${translation.x}px, ${translation.y}px)`;
  }

  animateCardInHandGapFill(card) {
    const cardSiblings = [...card.parentNode.children];
    const position = cardSiblings.indexOf(card);
    cardSiblings.slice(position + 1).forEach((card) => card.classList.add('card-to-left'));
    cardSiblings.slice(0, position).forEach((card) => card.classList.add('card-to-right'));
  }

  // Animations for a card entering the battlefield after being played
  // Triggering target: enterBattle

  enterBattleTargetConnected(card) {
    card.classList.add('last-played-card');
    card.onanimationend = () => { card.removeAttribute('data-animations-target'); card.classList.remove('last-played-card'); };
    const leftCards = [...document.getElementsByClassName('card-to-left')];
    leftCards.forEach((el) => {
      el.classList.remove('card-to-left');
      el.removeAttribute('data-animations-target');
    });
    const rightCards = [...document.getElementsByClassName('card-to-right')];
    rightCards.forEach((el) => {
      el.classList.remove('card-to-right');
      el.removeAttribute('data-animations-target');
    });
  }

  // Animations for when a card does not enter battle, but the translation animation phase
  // needs to be ended anyways.
  // Triggering target: fallbackForEndShift

  fallbackForEndShiftTargetConnected(element) {
    const leftCards = [...document.getElementsByClassName('card-to-left')];
    leftCards.forEach((el) => {
      el.classList.remove('card-to-left');
      el.removeAttribute('data-animations-target');
    });
    const rightCards = [...document.getElementsByClassName('card-to-right')];
    rightCards.forEach((el) => {
      el.classList.remove('card-to-right');
      el.removeAttribute('data-animations-target');
    });
    element.removeAttribute('data-animations-target');
  }

  // Animations for shifting entities to the left
  // Triggering target: shiftLeft

  shiftLeftTargetConnected(card) {
    card.classList.add('card-to-left');
  }

  // Animations for shifting entities to the right
  // Triggering target: shiftRight

  shiftRightTargetConnected(card) {
    card.classList.add('card-to-right');
  }

  // Animations for ending the mulligan phase of the gaame
  // Triggering Target: endMulliganPhase

  endMulliganPhaseTargetConnected() {
    const mulliganInfoBox = document.getElementById('mulligan-info-box');
    const mulliganCardBox = document.getElementById('mulligan-cards');

    mulliganInfoBox.classList.add('fade-out');
    mulliganInfoBox.onanimationend = () => {
      this.element.classList.remove('brightness-50');
      this.element.animate([{ filter: 'brightness(0.5)' }, { filter: 'brightness(1)' }], 2000);
      mulliganCardBox.classList.add('move-card-down');
    };
  }
}
