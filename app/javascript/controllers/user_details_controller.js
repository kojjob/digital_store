import { Controller } from "@hotwired/stimulus"

// Documentation: This controller manages the tabbed interface on the user details page
// It handles tab switching and ensures the correct content is displayed
export default class extends Controller {
  static targets = ["tab", "tabContent"]
  
  connect() {
    console.log("User details controller connected")
    // Set default tab on page load
    setTimeout(() => this.showTab("profile"), 100)
  }
  
  switchTab(event) {
    event.preventDefault()
    const tabName = event.currentTarget.getAttribute('data-tab')
    this.showTab(tabName)
  }
  
  showTab(tabName) {
    // Update active tab styling
    this.tabTargets.forEach(tab => {
      if (tab.getAttribute('data-tab') === tabName) {
        tab.classList.add('border-indigo-500', 'text-indigo-600')
        tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      } else {
        tab.classList.remove('border-indigo-500', 'text-indigo-600')
        tab.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })
    
    // Show/hide tab content
    this.tabContentTargets.forEach(content => {
      if (content.getAttribute('data-tab') === tabName) {
        content.classList.remove('hidden')
      } else {
        content.classList.add('hidden')
      }
    })
  }
}
