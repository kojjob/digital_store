import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "container", "input"]
  
  connect() {
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  handleKeydown(event) {
    // Close search with Escape key
    if (event.key === 'Escape' && !this.overlayTarget.classList.contains('hidden')) {
      this.close()
    }
    
    // Open search with Ctrl+K or Cmd+K
    if ((event.ctrlKey || event.metaKey) && event.key === 'k') {
      event.preventDefault()
      this.toggleSearch()
    }
  }
  
  toggleSearch() {
    if (this.overlayTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }
  
  open() {
    // Show overlay
    this.overlayTarget.classList.remove('hidden')
    
    // Add body scroll lock
    document.body.classList.add('overflow-hidden')
    
    // Animate overlay
    setTimeout(() => {
      this.overlayTarget.classList.remove('opacity-0')
      this.containerTarget.classList.remove('opacity-0', 'scale-95')
      this.containerTarget.classList.add('opacity-100', 'scale-100')
      
      // Focus search input
      this.inputTarget.focus()
    }, 10)
  }
  
  close() {
    // Animate overlay
    this.overlayTarget.classList.add('opacity-0')
    this.containerTarget.classList.remove('opacity-100', 'scale-100')
    this.containerTarget.classList.add('opacity-0', 'scale-95')
    
    // Hide overlay after animation completes
    setTimeout(() => {
      this.overlayTarget.classList.add('hidden')
      
      // Remove body scroll lock
      document.body.classList.remove('overflow-hidden')
    }, 300)
  }
}