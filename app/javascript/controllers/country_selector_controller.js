import BaseDropdownController from "./base_dropdown_controller"

export default class extends BaseDropdownController {
  // The base controller already defines "menu" target, so we don't need to redefine it
  // static targets = ["menu"]
  
  connect() {
    super.connect()
  }
  
  disconnect() {
    super.disconnect()
  }
  
  toggle(event) {
    super.toggle(event)
  }
  
  // All methods are inherited from the base controller
}