import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["testimonial"]
  
  connect() {
    this.setupIntersectionObserver()
  }
  
  setupIntersectionObserver() {
    // Create observer for testimonial animation
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          // Add staggered animation delay
          setTimeout(() => {
            entry.target.classList.add('opacity-100', 'translate-y-0')
            entry.target.classList.remove('opacity-0', 'translate-y-8')
          }, index * 200) // 200ms stagger for testimonials
          
          this.observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.2 })
    
    // Start observing testimonials
    this.testimonialTargets.forEach(testimonial => {
      testimonial.classList.add('opacity-0', 'translate-y-8', 'transition-all', 'duration-700')
      this.observer.observe(testimonial)
    })
  }
  
  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}