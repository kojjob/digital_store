import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "track", "indicators"]
  
  connect() {
    this.currentIndex = 0
    this.slideCount = this.trackTarget.children.length
    this.createIndicators()
    this.updateCarousel()
  }
  
  createIndicators() {
    for (let i = 0; i < this.slideCount; i++) {
      const indicator = document.createElement("button")
      indicator.classList.add("w-3", "h-3", "rounded-full", "mx-1", "bg-indigo-300")
      indicator.dataset.action = "carousel#goToSlide"
      indicator.dataset.index = i
      this.indicatorsTarget.appendChild(indicator)
    }
    this.updateIndicators()
  }
  
  next() {
    this.currentIndex = (this.currentIndex + 1) % this.slideCount
    this.updateCarousel()
  }
  
  previous() {
    this.currentIndex = (this.currentIndex - 1 + this.slideCount) % this.slideCount
    this.updateCarousel()
  }
  
  goToSlide(event) {
    this.currentIndex = parseInt(event.currentTarget.dataset.index)
    this.updateCarousel()
  }
  
  updateCarousel() {
    const slideWidth = this.containerTarget.clientWidth
    this.trackTarget.style.transform = `translateX(-${this.currentIndex * slideWidth}px)`
    this.updateIndicators()
  }
  
  updateIndicators() {
    const indicators = this.indicatorsTarget.children
    for (let i = 0; i < indicators.length; i++) {
      if (i === this.currentIndex) {
        indicators[i].classList.remove("bg-indigo-300")
        indicators[i].classList.add("bg-white")
      } else {
        indicators[i].classList.remove("bg-white")
        indicators[i].classList.add("bg-indigo-300")
      }
    }
  }
}