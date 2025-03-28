import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = {
    baseDelay: { type: Number, default: 5000 },  // Default delay before auto-dismissal
    staggerDelay: { type: Number, default: 200 } // Delay between messages
  }
  
  initialize() {
    // Track active timeouts so they can be cleared if needed
    this.dismissTimeouts = new Map()
  }
  
  connect() {
    // Process messages when the controller connects
    this.processMessages()
    
    // Set up to handle new flash messages that might be added later via AJAX
    this.mutationObserver = new MutationObserver((mutations) => {
      const newMessages = mutations
        .filter(mutation => mutation.type === 'childList' && mutation.addedNodes.length)
        .flatMap(mutation => Array.from(mutation.addedNodes))
        .filter(node => node.matches && node.matches('[data-flash-messages-target="message"]'))
      
      if (newMessages.length) {
        this.processMessages(newMessages)
      }
    })
    
    this.mutationObserver.observe(this.element, { childList: true })
  }
  
  disconnect() {
    // Clean up observer and timeouts
    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
    }
    
    this.dismissTimeouts.forEach(timeout => clearTimeout(timeout))
    this.dismissTimeouts.clear()
  }
  
  processMessages(messages = this.messageTargets) {
    messages.forEach((message, index) => {
      // Stagger the entrance of multiple messages
      setTimeout(() => {
        this.enterMessage(message)
      }, index * this.staggerDelayValue)
      
      // Get message-specific duration or use default
      const duration = parseInt(message.dataset.flashMessagesDuration || this.baseDelayValue)
      
      // Auto-dismiss after a delay
      const timeout = setTimeout(() => {
        this.dismiss(message)
      }, duration + (index * this.staggerDelayValue))
      
      // Store the timeout ID so we can clear it if needed
      this.dismissTimeouts.set(message, timeout)
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
    // Clear any pending timeout for this message
    if (this.dismissTimeouts.has(message)) {
      clearTimeout(this.dismissTimeouts.get(message))
      this.dismissTimeouts.delete(message)
    }
    
    // Only dismiss if the message still exists in the DOM
    if (this.element.contains(message)) {
      const leaveFrom = message.dataset.transitionLeaveFrom.split(' ')
      const leaveTo = message.dataset.transitionLeaveTo.split(' ')
      
      // Add transition classes for smooth animation
      message.classList.remove(...leaveFrom)
      message.classList.add('transition', 'duration-300', ...leaveTo)
      
      // Remove from DOM after animation completes
      setTimeout(() => {
        message.remove()
      }, 300) // Match to your transition duration
    }
  }
  
  close(event) {
    const message = event.target.closest('[data-flash-messages-target="message"]')
    this.dismiss(message)
  }
}