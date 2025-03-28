import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    // Add document event listener for escape key
    this.escapeHandler = this.escapeKeyPressed.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.escapeHandler)
    
    // Ensure body scrolling is enabled when element is removed
    document.body.style.overflow = ''
  }
  
  open() {
    if (this.hasOverlayTarget) {
      // Show the overlay
      this.overlayTarget.classList.remove('hidden')
      
      // Force a reflow before setting opacity for animation
      void this.overlayTarget.offsetHeight
      
      // Animate in
      this.overlayTarget.classList.remove('opacity-0')
      
      // Prevent scrolling
      document.body.style.overflow = 'hidden'
      
      // Focus the search input
      const searchInput = this.overlayTarget.querySelector('input')
      if (searchInput) {
        setTimeout(() => {
          searchInput.focus()
        }, 100)
      }
    }
  }
  
  close() {
    if (this.hasOverlayTarget) {
      // Animate out
      this.overlayTarget.classList.add('opacity-0')
      
      // Hide after animation
      setTimeout(() => {
        this.overlayTarget.classList.add('hidden')
        
        // Re-enable scrolling
        document.body.style.overflow = ''
      }, 300)
    }
  }
  
  escapeKeyPressed(event) {
    if (event.key === 'Escape' && 
        this.hasOverlayTarget && 
        !this.overlayTarget.classList.contains('hidden')) {
      this.close()
    }
  }
}
