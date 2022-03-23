import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="style-cards"
export default class extends Controller {
  static targets = ['boardMinion', 'player'];

  boardMinionTargetConnected(element) {
    this.styleHealthPoints(element)
  }

  playerTargetConnected(element){
    this.styleHealthPoints(element)
  }

  styleHealthPoints(element){
    const healthIndicator = element.querySelector("#health")
    if (+healthIndicator.innerText < element.dataset.healthCap){
      healthIndicator.classList.add('text-red-500');
    }
  }
}
