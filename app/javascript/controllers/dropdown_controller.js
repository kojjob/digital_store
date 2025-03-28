import BaseDropdownController from "./base_dropdown_controller"

export default class extends BaseDropdownController {
  // Properly inherit targets from the base controller while adding our own
  static targets = ["menu", "label", "selected"]
  
  connect() {
    super.connect()
  }
  
  disconnect() {
    super.disconnect()
  }

  toggle(event) {
    // Ensure we prevent default action and stop propagation
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    super.toggle(event)
  }

  select(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    const value = event.currentTarget.dataset.value || event.currentTarget.textContent.trim()
    
    if (this.hasSelectedTarget) {
      this.selectedTarget.textContent = value
    } else if (this.hasLabelTarget) {
      this.labelTarget.textContent = value
    }
    
    // Hide the dropdown after selection
    this.hide()
  }
}