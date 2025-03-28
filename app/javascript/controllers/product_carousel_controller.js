import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "track"]
  
  connect() {
    this.itemWidth = 288 // w-72 in TailwindCSS (includes gaps)
    this.currentPosition = 0
    this.itemsPerScreen = Math.floor(this.containerTarget.offsetWidth / this.itemWidth)
    this.maxPosition = this.trackTarget.children.length - this.itemsPerScreen
    
    // Add resize handler
    this.resizeObserver = new ResizeObserver(entries => {
      this.itemsPerScreen = Math.floor(this.containerTarget.offsetWidth / this.itemWidth)
      this.maxPosition = this.trackTarget.children.length - this.itemsPerScreen
      this.updatePosition()
    })
    
    this.resizeObserver.observe(this.containerTarget)
  }
  
  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
  }
  
  next() {
    this.currentPosition = Math.min(this.currentPosition + 1, this.maxPosition)
    this.updatePosition()
  }
  
  previous() {
    this.currentPosition = Math.max(this.currentPosition - 1, 0)
    this.updatePosition()
  }
  
  updatePosition() {
    const translateX = this.currentPosition * -this.itemWidth
    this.trackTarget.style.transform = `translateX(${translateX}px)`
  }
}