import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Store bound methods as properties for proper removal
    this._outsideClickHandler = this.outsideClick.bind(this)
    this._keydownHandler = this.handleKeydown.bind(this)
    
    // Add global event listeners
    this.addGlobalListeners()
  }
  
  disconnect() {
    // Remove global event listeners
    this.removeGlobalListeners()
    
    // Clean up any pending timeouts
    if (this._showTimeout) clearTimeout(this._showTimeout)
    if (this._hideTimeout) clearTimeout(this._hideTimeout)
  }
  
  addGlobalListeners() {
    document.addEventListener('click', this._outsideClickHandler)
    document.addEventListener('keydown', this._keydownHandler)
  }
  
  removeGlobalListeners() {
    document.removeEventListener('click', this._outsideClickHandler)
    document.removeEventListener('keydown', this._keydownHandler)
  }
  
  outsideClick(event) {
    // Only process if menu is visible and click is outside dropdown
    if (this.menuTarget && 
        !this.menuTarget.classList.contains('hidden') && 
        !this.element.contains(event.target)) {
      this.hide()
    }
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.hide()
    }
  }
  
  toggle(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    if (this.menuTarget.classList.contains('hidden')) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    // Clear any pending hide timeout
    if (this._hideTimeout) {
      clearTimeout(this._hideTimeout)
      this._hideTimeout = null
    }
    
    // Make element visible first
    this.menuTarget.classList.remove('hidden')
    
    // Force a browser reflow to ensure transitions work
    void this.menuTarget.offsetHeight
    
    // Apply the animation classes
    setTimeout(() => {
      if (!this.menuTarget) return // Guard against disconnect
      
      this.menuTarget.classList.add('opacity-100', 'translate-y-0')
      this.menuTarget.classList.remove('opacity-0', 'translate-y-1')
    }, 0)
  }

  hide() {
    // Clear any pending show timeout
    if (this._showTimeout) {
      clearTimeout(this._showTimeout)
      this._showTimeout = null
    }
    
    // Don't proceed if already hidden
    if (!this.menuTarget || this.menuTarget.classList.contains('hidden')) return
    
    // First add animation classes for fade-out
    this.menuTarget.classList.remove('opacity-100', 'translate-y-0')
    this.menuTarget.classList.add('opacity-0', 'translate-y-1')
    
    // Then hide after animation completes
    this._hideTimeout = setTimeout(() => {
      if (!this.menuTarget) return // Guard against disconnect
      
      this.menuTarget.classList.add('hidden')
      this._hideTimeout = null
    }, 200) // Match this with CSS transition time
  }
}