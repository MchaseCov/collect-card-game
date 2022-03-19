import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="line-drawer"
export default class extends Controller {
  static targets = ['origin', 'canvas'];

  originTargetConnected(element) {
    this.canvasTarget.setAttribute('data-action', 'resize@window->line-drawer#resizeActiveCanvas');
    this.setCanvasSizeAndContext();
    this.styleCursors();
    this.createLine(element);
  }

  styleCursors() {
    this.originTarget.style.cursor = "url('/cancelAction.webp') 20 20, pointer";
    this.element.style.cursor = "url('/reticle.webp') 10 15, crosshair";
  }

  originTargetDisconnected(element) {
    this.stopDrawing();
    this.element.style.cursor = 'auto';
    element.style.cursor = "auto";
  }

  disconnectOriginTarget() {
    this.originTarget.removeAttribute('data-line-drawer-target');
  }

  clearCanvas() {
    this.canvasContext.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height);
  }

  stopDrawing() {
    this.element.removeAttribute('data-action');
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
    context.setLineDash([20, 5]);
    return context;
  }

  setCanvasSizeAndContext() {
    this.setCanvasElementSize();
    this.canvasContext = this.setCanvasContext();
  }

  resizeActiveCanvas() {
    this.clearCanvas();
    this.setCanvasSizeAndContext();
    this.createLine(this.originTarget);
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
    this.element.dataset.action += " mousemove->line-drawer#updateLine"
  }
}
