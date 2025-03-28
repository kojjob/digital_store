import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview"]

  connect() {
    // Add document event listener for clicks outside
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
    
    // Add escape key handler
    this.escapeHandler = this.escapeKeyPressed.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
    
    // Initialize preview with opacity-0 and translate-y-1 classes
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add('opacity-0', 'translate-y-1')
    }
    
    // Set timeout variables
    this._showTimeout = null
    this._hideTimeout = null
    this._hoverDelay = 300 // ms delay for showing on hover
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener('click', this.clickOutsideHandler)
    document.removeEventListener('keydown', this.escapeHandler)
    
    // Clear any timeouts
    if (this._showTimeout) clearTimeout(this._showTimeout)
    if (this._hideTimeout) clearTimeout(this._hideTimeout)
  }
  
  toggle(event) {
    // Ensure we capture and stop the event
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    const isHidden = this.previewTarget.classList.contains('hidden')
    
    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }
  
  show() {
    // Clear any pending hide
    if (this._hideTimeout) {
      clearTimeout(this._hideTimeout)
      this._hideTimeout = null
    }
    
    // Only schedule show if currently hidden
    if (this.previewTarget.classList.contains('hidden')) {
      this._showTimeout = setTimeout(() => {
        this.open()
      }, this._hoverDelay)
    }
  }
  
  hide() {
    // Clear any pending show
    if (this._showTimeout) {
      clearTimeout(this._showTimeout) 
      this._showTimeout = null
    }
    
    // Only schedule hide if currently visible
    if (!this.previewTarget.classList.contains('hidden')) {
      this._hideTimeout = setTimeout(() => {
        this.close()
      }, this._hoverDelay)
    }
  }
  
  open() {
    if (!this.hasPreviewTarget) return
    
    // Cancel any pending hide operation
    if (this._hideTimeout) {
      clearTimeout(this._hideTimeout)
      this._hideTimeout = null
    }
    
    // Show this dropdown
    this.previewTarget.classList.remove('hidden')
    
    // Important: Force a reflow before changing animation properties
    void this.previewTarget.offsetHeight
    
    // Add animation classes
    this.previewTarget.classList.add('opacity-100', 'translate-y-0')
    this.previewTarget.classList.remove('opacity-0', 'translate-y-1')
  }
  
  close() {
    if (!this.hasPreviewTarget) return
    
    // Cancel any pending show operation
    if (this._showTimeout) {
      clearTimeout(this._showTimeout)
      this._showTimeout = null
    }
    
    if (this.previewTarget.classList.contains('hidden')) return
    
    // First remove animation classes for smooth transition
    this.previewTarget.classList.remove('opacity-100', 'translate-y-0')
    this.previewTarget.classList.add('opacity-0', 'translate-y-1')
    
    // Then hide after animation
    this._hideTimeout = setTimeout(() => {
      if (!this.previewTarget) return // Guard against disconnection
      
      this.previewTarget.classList.add('hidden')
      this._hideTimeout = null
    }, 200)
  }
  
  clickOutside(event) {
    // Close if clicked outside and preview is open
    if (this.hasPreviewTarget && 
        !this.element.contains(event.target) && 
        !this.previewTarget.classList.contains('hidden')) {
      this.close()
    }
  }
  
  escapeKeyPressed(event) {
    // Close on escape key
    if (event.key === 'Escape' && 
        this.hasPreviewTarget && 
        !this.previewTarget.classList.contains('hidden')) {
      this.close()
    }
  }
}
