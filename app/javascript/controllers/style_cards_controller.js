import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="style-cards"
export default class extends Controller {
  static targets = ['boardMinion', 'player', 'tauntingCard'];

  boardMinionTargetConnected(element) {
    this.styleHealthPoints(element)
  }

  playerTargetConnected(element){
    this.styleHealthPoints(element)
  }

  tauntingCardTargetConnected(element){
    element.classList.add("rounded-t-none", "border-4")
    element.querySelector("#art").classList.add("rounded-t-none")
  }

  styleHealthPoints(element){
    const healthIndicator = element.querySelector("#health")
    if (+healthIndicator.innerText < element.dataset.healthCap){
      healthIndicator.classList.add('text-red-500');
    }
  }
}
