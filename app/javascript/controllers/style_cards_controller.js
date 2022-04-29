import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="style-cards"
export default class extends Controller {
  static targets = ['boardMinion', 'player', 'tauntingCard'];

  tauntingCardTargetConnected(element){
    element.classList.add("rounded-t-none", "border-4")
    element.querySelector("#art").classList.add("rounded-t-none")
  }

}
