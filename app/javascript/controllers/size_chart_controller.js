import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "openButton", "closeButton", "backdrop"]
  
  connect() {
    // Set up keyboard event listener
    document.addEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  disconnect() {
    // Clean up keyboard event listener
    document.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  open(event) {
    event.preventDefault()
    
    this.modalTarget.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
    
    // Focus on close button for accessibility
    setTimeout(() => {
      this.closeButtonTarget.focus()
    }, 100)
  }
  
  close() {
    this.modalTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
    
    // Return focus to the open button for accessibility
    if (this.hasOpenButtonTarget) {
      this.openButtonTarget.focus()
    }
  }
  
  clickBackdrop(event) {
    // Only close if clicking directly on the backdrop, not its children
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }
  
  handleKeyDown(event) {
    // Close modal on Escape key
    if (event.key === 'Escape' && !this.modalTarget.classList.contains('hidden')) {
      this.close()
    }
  }
}
