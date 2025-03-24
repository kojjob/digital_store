import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  
  connect() {
    this.messageTargets.forEach((message, index) => {
      // Stagger the entrance of multiple messages
      setTimeout(() => {
        this.enterMessage(message)
      }, index * 200)
      
      // Auto-dismiss after a delay
      setTimeout(() => {
        this.dismiss(message)
      }, 5000 + (index * 200)) // 5 seconds + stagger time
    })
  }
  
  enterMessage(message) {
    const enterFrom = message.dataset.transitionEnterFrom.split(' ')
    const enterTo = message.dataset.transitionEnterTo.split(' ')
    
    // Remove enterFrom classes and add enterTo classes
    message.classList.remove(...enterFrom)
    message.classList.add(...enterTo)
  }
  
  dismiss(message) {
    // Only dismiss if the message still exists in the DOM
    if (this.element.contains(message)) {
      const leaveFrom = message.dataset.transitionLeaveFrom.split(' ')
      const leaveTo = message.dataset.transitionLeaveTo.split(' ')
      
      // Remove leaveFrom classes and add leaveTo classes
      message.classList.remove(...leaveFrom)
      message.classList.add(...leaveTo)
      
      // Remove from DOM after animation completes
      setTimeout(() => {
        message.remove()
      }, 500) // Match to your transition duration
    }
  }
  
  close(event) {
    const message = event.target.closest('[data-flash-messages-target="message"]')
    this.dismiss(message)
  }
}