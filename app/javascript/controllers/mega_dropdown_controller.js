import BaseDropdownController from "./base_dropdown_controller"

export default class extends BaseDropdownController {
  // Need to explicitly define the targets due to Stimulus not inheriting them
  static targets = ["menu"]
  
  connect() {
    super.connect()
    // Add any specific initialization for mega dropdown
  }
  
  disconnect() {
    super.disconnect()
  }
  
  toggle(event) {
    // Make sure we handle the event properly
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    // Let the base controller handle the actual toggle logic
    super.toggle(event)
  }
  
  // Override the show method if needed
  show() {
    // Close any other open dropdowns first
    document.querySelectorAll('[data-dropdown-target="menu"]:not(.hidden), [data-mega-dropdown-target="menu"]:not(.hidden)')
      .forEach(menu => {
        if (menu !== this.menuTarget) {
          const controller = this.application.getControllerForElementAndIdentifier(
            menu.closest('[data-controller="dropdown"], [data-controller="mega-dropdown"]'),
            menu.closest('[data-controller="dropdown"]') ? 'dropdown' : 'mega-dropdown'
          )
          if (controller && typeof controller.hide === 'function') {
            controller.hide()
          }
        }
      })
    
    // Then show this dropdown
    super.show()
  }
  
  // Override the hide method if needed
  hide() {
    super.hide()
  }
}