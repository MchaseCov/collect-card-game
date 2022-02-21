import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="animations"
export default class extends Controller {
  static targets = ['battlefield', 'player'];

  static values = {
    attacker: Object, defender: Object,
  };

  defenderValueChanged() {
    const defender = this.getActorFromObject(this.defenderValue);
    const attacker = this.getActorFromObject(this.attackerValue);
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
        return this.playerTargets.find((el) => el.dataset.playerId === id);
      default:
        return false;
    }
  }

  findDifferenceInPositions(attacker, target) {
    attacker.classList.add('z-50', 'board-animatable');
    const attackerCoords = attacker.getBoundingClientRect();
    const targetCoords = target.getBoundingClientRect();
    const translation = {
      x: (targetCoords.x - attackerCoords.x) * 0.75,
      y: (targetCoords.y - attackerCoords.y) * 0.75,
    };
    return translation;
  }

  translateToAndFrom(actor, translation) {
    actor.animate(
      [{ transform: 'translate(0, 0)', easing: 'ease-out' },
        { transform: `translate(${~~translation.x}px, ${~~translation.y}px)` },
        { transform: 'translate(0, 0)', easing: 'ease-in' }],
      500,
    );
  }
}
