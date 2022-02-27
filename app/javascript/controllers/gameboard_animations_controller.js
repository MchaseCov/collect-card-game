import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gameboard-animations"
export default class extends Controller {
  static targets = ['mulliganRegion']
  static values = { status: String }

  statusValueChanged(value){
    switch (value) {
      case "mulligan":
        this.element.parentElement.classList.add('brightness-50');
        break;
      default:
    }
  }
  mulliganRegionTargetConnected(element){
    this.element.parentElement.parentElement.appendChild(element)
  }
  mulliganRegionTargetDisconnected(element){
    element.remove()
  }
}
