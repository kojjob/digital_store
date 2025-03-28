import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["element"]
  
  connect() {
    // Add observer for elements that should animate on page load
    this.animateOnLoad()
  }
  
  animateOnLoad() {
    this.elementTargets.forEach(element => {
      // Get animation delay if specified
      const delay = element.dataset.animationDelay || 0
      
      // Get animation classes
      const animationClass = element.dataset.animationClass || "opacity-100"
      const initialClass = element.dataset.animationInitialClass || "opacity-0"
      
      // Set initial state
      element.classList.add(...initialClass.split(" "))
      
      // Trigger animation after delay
      setTimeout(() => {
        element.classList.remove(...initialClass.split(" "))
        element.classList.add(...animationClass.split(" "))
      }, parseInt(delay))
    })
  }
}