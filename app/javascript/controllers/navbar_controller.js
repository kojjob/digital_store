import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuOpen", "menuClose", "mobileMenu"]
  
  connect() {
    // Initialize mobile menu state
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.add('max-h-0')
    }
  }
  
  toggleMobileMenu() {
    if (this.hasMobileMenuTarget) {
      if (this.mobileMenuTarget.classList.contains('max-h-0')) {
        // Show mobile menu
        this.menuOpenTarget.classList.add('hidden')
        this.menuCloseTarget.classList.remove('hidden')
        
        // Animate opening
        this.mobileMenuTarget.classList.remove('max-h-0')
        const height = this.mobileMenuTarget.scrollHeight
        this.mobileMenuTarget.style.maxHeight = `${height}px`
      } else {
        // Hide mobile menu
        this.menuCloseTarget.classList.add('hidden')
        this.menuOpenTarget.classList.remove('hidden')
        
        // Animate closing
        this.mobileMenuTarget.style.maxHeight = '0px'
        
        // Reset class after animation completes
        setTimeout(() => {
          this.mobileMenuTarget.classList.add('max-h-0')
          this.mobileMenuTarget.style.maxHeight = ''
        }, 300)
      }
    }
  }
}