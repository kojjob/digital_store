import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Close dropdown when clicking elsewhere
    document.addEventListener('click', this.handleDocumentClick.bind(this))
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.handleDocumentClick.bind(this))
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.hide()
    }
  }
  
  toggle(event) {
    event.stopPropagation()
    
    if (this.menuTarget.classList.contains('hidden')) {
      this.show()
    } else {
      this.hide()
    }
  }
  
  show() {
    this.menuTarget.classList.remove('hidden', 'opacity-0', 'scale-95')
    this.menuTarget.classList.add('opacity-100', 'scale-100')
  }
  
  hide() {
    this.menuTarget.classList.remove('opacity-100', 'scale-100')
    this.menuTarget.classList.add('opacity-0', 'scale-95')
    
    // Hide after animation
    setTimeout(() => {
      if (this.menuTarget) { // Check if target still exists
        this.menuTarget.classList.add('hidden')
      }
    }, 200)
  }
}