import { Controller } from '@hotwired/stimulus';


// Connects to data-controller="line-drawer"
export default class extends Controller {
  static targets = ['origin', 'canvas'];
  
  originTargetConnected(element) {
    this.gameEle = document.getElementById('main-game-board')
    this.canvasTarget.setAttribute('data-action', 'resize@window->line-drawer#resizeActiveCanvas');
    this.setCanvasSizeAndContext();
    this.styleCursors();
    this.createLine(element);
  }

  styleCursors() {
    this.originTarget.style.cursor = "url('/cancelAction.webp') 20 20, pointer";
    this.gameEle.style.cursor = "url('/reticle.webp') 10 15, crosshair";
  }

  originTargetDisconnected(element) {
    this.stopDrawing();
    this.gameEle.style.cursor = 'auto';
    element.style.cursor = "auto";
    this.canvasTarget.removeAttribute('data-action')
  }

  disconnectOriginTarget() {
    this.originTarget.removeAttribute('data-line-drawer-target');
  }

  clearCanvas() {
    this.canvasContext.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height);
  }

  stopDrawing() {
    this.gameEle.removeAttribute('data-action');
    this.clearCanvas();
  }

  setCanvasElementSize() {
    this.canvasTarget.width = window.innerWidth;
    this.canvasTarget.height = window.innerHeight;
  }

  setCanvasContext() {
    const context = this.canvasTarget.getContext('2d');
    context.lineWidth = 8;
    context.strokeStyle = 'red';
    context.shadowOffsetX = 4;
    context.shadowOffsetY = 10;
    context.shadowBlur    = 12;
    context.shadowColor   = "#78350f";
    context.lineCap = 'round';
    context.setLineDash([20, 15]);
    return context;
  }

  setCanvasSizeAndContext() {
    this.setCanvasElementSize();
    this.canvasContext = this.setCanvasContext();
  }

  resizeActiveCanvas() {
    this.clearCanvas();
    this.setCanvasSizeAndContext();
    if(this.originTarget)this.createLine(this.originTarget);
  }

  updateLine(event) {
    this.lineCoordinates = this.getClientOffset(event);
    this.clearCanvas();
    this.drawLine();
  }

  getClientOffset(event) {
    const { pageX, pageY } = event.touches ? event.touches[0] : event;
    const x = pageX - this.canvasTarget.offsetLeft;
    const y = pageY - this.canvasTarget.offsetTop;

    return { x, y };
  }

  drawLine() {
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(this.startPosition.x, this.startPosition.y);
    this.canvasContext.lineTo(this.lineCoordinates.x, this.lineCoordinates.y);
    this.canvasContext.stroke();
  }

  createLine(element) {
    const {
      left, top, width, height,
    } = element.getBoundingClientRect();
    const centerX = left + width / 2;
    const centerY = top + height / 2;
    this.startPosition = { x: centerX, y: centerY };
    this.lineCoordinates = { x: 0, y: 0 };
    this.gameEle.dataset.action += " mousemove->line-drawer#updateLine"
  }
}
