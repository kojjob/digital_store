import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feature"]

  connect() {
    this.setupIntersectionObserver()
    this.setupHoverEffects()
  }
  
  setupIntersectionObserver() {
    // Create IntersectionObserver for fade-in animations
    const options = {
      root: null, // Use viewport as root
      rootMargin: '0px',
      threshold: 0.1 // Trigger when 10% of element is visible
    }
    
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          // Add staggered animation delay
          setTimeout(() => {
            entry.target.classList.add('opacity-100', 'translate-y-0')
            entry.target.classList.remove('opacity-0', 'translate-y-8')
          }, index * 100) // 100ms stagger between each item
          
          // Stop observing once animation is applied
          this.observer.unobserve(entry.target)
        }
      })
    }, options)
    
    // Start observing all feature targets
    this.featureTargets.forEach((feature, index) => {
      // Set initial state
      feature.classList.add('opacity-0', 'translate-y-8', 'transition-all', 'duration-700')
      this.observer.observe(feature)
    })
  }
  
  setupHoverEffects() {
    // Add interactive hover effects
    this.featureTargets.forEach(feature => {
      feature.addEventListener('mouseenter', () => {
        // Add shadow pulse animation on hover
        feature.classList.add('shadow-pulse')
      })
      
      feature.addEventListener('mouseleave', () => {
        // Remove animation when mouse leaves
        feature.classList.remove('shadow-pulse')
      })
    })
  }
  
  disconnect() {
    // Clean up observer when controller disconnects
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}