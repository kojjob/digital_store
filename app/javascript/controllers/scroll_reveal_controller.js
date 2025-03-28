import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["element"]
  
  connect() {
    // Initialize intersection observer
    this.observer = new IntersectionObserver(this.handleIntersect.bind(this), {
      root: null,
      rootMargin: '0px',
      threshold: 0.1
    })
    
    // Observe all elements
    this.elementTargets.forEach(element => {
      // Set initial state (hidden)
      element.classList.add('opacity-0', 'translate-y-8')
      element.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out'
      
      // Start observing
      this.observer.observe(element)
    })
  }
  
  disconnect() {
    // Clean up observer when controller disconnects
    this.observer.disconnect()
  }
  
  handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const element = entry.target
        const delay = element.dataset.scrollRevealDelay || 0
        
        // Reveal the element with delay if specified
        setTimeout(() => {
          element.classList.remove('opacity-0', 'translate-y-8')
          element.classList.add('opacity-100', 'translate-y-0')
        }, parseInt(delay))
        
        // Stop observing once revealed
        this.observer.unobserve(element)
      }
    })
  }
}