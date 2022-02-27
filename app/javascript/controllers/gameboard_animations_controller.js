import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gameboard-animations"
export default class extends Controller {
  static targets = ['mulliganRegion']
  static values = { status: String, turn: String }

  statusValueChanged(value){
    switch (value) {
      case "mulligan":
        this.element.parentElement.classList.add('brightness-50');
        break;
      default:
    }
  }

  connect(){
  const turnTime = Date.parse(this.turnValue)
  this.turnCount = setInterval(function() {
    if ((Date.now()-turnTime)>= 120000){
      clearInterval(this.turnCount);
    } else {
    }
  
  }, 1000);
}

  disconnect(){
    clearInterval(this.turnCount)
  }


  mulliganRegionTargetConnected(element){
    this.element.parentElement.parentElement.appendChild(element)
  }
  mulliganRegionTargetDisconnected(element){
    element.remove()
  }
}
