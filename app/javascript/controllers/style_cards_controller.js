import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="style-cards"
export default class extends Controller {
  static targets = ['boardMinion'];

  boardMinionTargetConnected(element) {
    if (element.dataset.healthCurrent < element.dataset.healthCap){
      element.querySelector(".health-current").classList.add('text-red-500');
    }
  }
}
