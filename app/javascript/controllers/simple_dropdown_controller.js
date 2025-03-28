import { Controller } from "@hotwired/stimulus"

// A simplified, direct dropdown controller without inheritance complications
export default class extends Controller {
  static targets = ["button", "menu"]
  
  connect() {
    // Add document event listener for clicks outside
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
    
    // Add escape key handler
    this.escapeHandler = this.escapeKeyPressed.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
    
    // Initialize menu with opacity-0 and translate-y-1 classes
    this.menuTarget.classList.add('opacity-0', 'translate-y-1')
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
    
    const isHidden = this.menuTarget.classList.contains('hidden')
    
    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }
  
  open() {
    // Cancel any pending hide operation
    if (this._hideTimeout) {
      clearTimeout(this._hideTimeout)
      this._hideTimeout = null
    }
    
    // Close all other simple dropdowns first
    document.querySelectorAll('[data-simple-dropdown-target="menu"]:not(.hidden)').forEach(menu => {
      if (menu !== this.menuTarget) {
        const element = menu.closest('[data-controller="simple-dropdown"]')
        if (element) {
          // Try to get controller using Stimulus
          const controller = this.application.getControllerForElementAndIdentifier(element, 'simple-dropdown')
          if (controller && controller !== this) {
            controller.close()
          } else {
            // Fallback if getting controller fails
            menu.classList.add('opacity-0', 'translate-y-1')
            setTimeout(() => { menu.classList.add('hidden') }, 200)
          }
        }
      }
    })
    
    // Show this dropdown
    this.menuTarget.classList.remove('hidden')
    this.element.classList.add('dropdown-active')
    
    // Important: Force a reflow before changing animation properties
    void this.menuTarget.offsetHeight
    
    // Add animation classes
    this._showTimeout = setTimeout(() => {
      if (!this.menuTarget) return // Guard against disconnection
      
      this.menuTarget.classList.add('opacity-100', 'translate-y-0')
      this.menuTarget.classList.remove('opacity-0', 'translate-y-1')
      this._showTimeout = null
    }, 10)
  }
  
  close() {
    // Cancel any pending show operation
    if (this._showTimeout) {
      clearTimeout(this._showTimeout)
      this._showTimeout = null
    }
    
    if (this.menuTarget.classList.contains('hidden')) return
    
    // First remove animation classes for smooth transition
    this.menuTarget.classList.remove('opacity-100', 'translate-y-0')
    this.menuTarget.classList.add('opacity-0', 'translate-y-1')
    this.element.classList.remove('dropdown-active')
    
    // Then hide after animation
    this._hideTimeout = setTimeout(() => {
      if (!this.menuTarget) return // Guard against disconnection
      
      this.menuTarget.classList.add('hidden')
      this._hideTimeout = null
    }, 200)
  }
  
  select(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    if (this.hasButtonTarget) {
      try {
        const selectedText = event.currentTarget.textContent.trim()
        const buttonSpan = this.buttonTarget.querySelector('span')
        if (buttonSpan) {
          buttonSpan.textContent = selectedText
        }
      } catch (e) {
        console.error("Error updating button text:", e)
      }
    }
    
    this.close()
  }
  
  clickOutside(event) {
    // Close if clicked outside and menu is open
    if (!this.element.contains(event.target) && 
        !this.menuTarget.classList.contains('hidden')) {
      this.close()
    }
  }
  
  escapeKeyPressed(event) {
    // Close on escape key
    if (event.key === 'Escape' && !this.menuTarget.classList.contains('hidden')) {
      this.close()
    }
  }
}