import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sessionsList"]

  connect() {
    console.log("Session manager controller connected")
  }

  terminateSession(event) {
    event.preventDefault()
    const sessionId = event.currentTarget.dataset.sessionId
    
    if (confirm("Are you sure you want to sign out this session?")) {
      // In a real application, you would make an AJAX request to your server
      // to invalidate the specified session
      
      // For demo purposes, we'll just remove the session from the list
      const sessionItem = event.currentTarget.closest("li")
      sessionItem.classList.add("bg-red-50")
      
      // Animate removal
      setTimeout(() => {
        sessionItem.style.transition = "opacity 0.5s, height 0.5s"
        sessionItem.style.opacity = "0"
        sessionItem.style.height = "0"
        sessionItem.style.overflow = "hidden"
        
        setTimeout(() => {
          sessionItem.remove()
          this.checkEmptySessions()
        }, 500)
      }, 300)
      
      // Show feedback message (would be handled by response in real app)
      this.showNotification("Session successfully terminated")
    }
  }
  
  terminateAllSessions(event) {
    event.preventDefault()
    
    if (confirm("Are you sure you want to sign out all other sessions? This will log you out from all other devices.")) {
      // In a real application, you would make an AJAX request to your server
      // to invalidate all sessions except the current one
      
      // For demo purposes, we'll just remove all sessions from the list
      const sessionItems = this.sessionsListTarget.querySelectorAll("li")
      
      sessionItems.forEach((item, index) => {
        item.classList.add("bg-red-50")
        
        // Animate removal with staggered delay
        setTimeout(() => {
          item.style.transition = "opacity 0.5s, height 0.5s"
          item.style.opacity = "0"
          item.style.height = "0"
          item.style.overflow = "hidden"
          
          setTimeout(() => {
            item.remove()
            this.checkEmptySessions()
          }, 500)
        }, 100 * index)
      })
      
      // Show feedback message (would be handled by response in real app)
      this.showNotification("All other sessions successfully terminated")
    }
  }
  
  checkEmptySessions() {
    if (this.sessionsListTarget.querySelectorAll("li").length === 0) {
      this.sessionsListTarget.innerHTML = `
        <li class="px-4 py-6 text-center">
          <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">No other active sessions</h3>
          <p class="mt-1 text-sm text-gray-500">
            You're only signed in on this device.
          </p>
        </li>
      `
    }
  }
  
  showNotification(message) {
    // Create notification element
    const notification = document.createElement("div")
    notification.className = "fixed top-16 inset-x-0 flex items-center justify-center z-50 animate-fadeIn"
    notification.innerHTML = `
      <div class="bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center max-w-md">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
        </svg>
        <span>${message}</span>
      </div>
    `
    
    // Add to DOM
    document.body.appendChild(notification)
    
    // Remove after 3 seconds
    setTimeout(() => {
      notification.classList.add("animate-fadeOut")
      setTimeout(() => {
        notification.remove()
      }, 500)
    }, 3000)
  }
}