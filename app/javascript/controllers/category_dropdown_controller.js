import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "selected"]
  
  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.outsideClick.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.outsideClick.bind(this))
  }
  
  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('hidden')
  }
  
  select(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    this.selectedTarget.textContent = value
    this.menuTarget.classList.add('hidden')
    
    // In a real app, this would navigate to the URL or trigger a filter
    // window.location.href = event.currentTarget.href
  }
  
  outsideClick(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('hidden')) {
      this.menuTarget.classList.add('hidden')
    }
  }
}
