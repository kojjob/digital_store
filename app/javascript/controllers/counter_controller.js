import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["number"]
  
  connect() {
    // Only animate if in viewport
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const target = entry.target
          if (target.dataset.counterAnimated !== "true") {
            this.animateCounter(target)
            target.dataset.counterAnimated = "true"
          }
        }
      })
    }, { threshold: 0.1 })
    
    this.numberTargets.forEach(number => {
      this.observer.observe(number)
    })
  }
  
  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
  
  animateCounter(element) {
    const targetValue = parseInt(element.dataset.value, 10)
    const duration = 2000 // ms
    const frameDuration = 1000 / 60 // 60fps
    const totalFrames = Math.round(duration / frameDuration)
    
    let frame = 0
    const counter = setInterval(() => {
      frame++
      
      // Easing function (easeOutCubic)
      const progress = 1 - Math.pow(1 - frame / totalFrames, 3)
      const currentValue = Math.floor(targetValue * progress)
      
      element.textContent = currentValue.toLocaleString()
      
      if (frame === totalFrames) {
        clearInterval(counter)
      }
    }, frameDuration)
  }
}