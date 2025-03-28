import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    title: String
  }
  
  connect() {
    // Set default values if not provided
    this.urlValue = this.urlValue || window.location.href
    this.titleValue = this.titleValue || document.title
  }
  
  shareWhatsApp(event) {
    event.preventDefault()
    const url = `https://wa.me/?text=${encodeURIComponent(`${this.titleValue}: ${this.urlValue}`)}`
    this.openShareWindow(url)
  }
  
  shareFacebook(event) {
    event.preventDefault()
    const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlValue)}`
    this.openShareWindow(url)
  }
  
  shareTwitter(event) {
    event.preventDefault()
    const url = `https://twitter.com/intent/tweet?url=${encodeURIComponent(this.urlValue)}&text=${encodeURIComponent(this.titleValue)}`
    this.openShareWindow(url)
  }
  
  shareEmail(event) {
    event.preventDefault()
    const url = `mailto:?subject=${encodeURIComponent(this.titleValue)}&body=${encodeURIComponent(`Check out this product: ${this.urlValue}`)}`
    window.location.href = url
  }
  
  copyLink(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.urlValue)
      .then(() => this.showNotification('Link copied to clipboard!'))
      .catch(error => console.error('Could not copy link:', error))
  }
  
  openShareWindow(url) {
    window.open(url, '_blank', 'width=600,height=450,toolbar=0,location=0,menubar=0')
  }
  
  showNotification(message) {
    // Create notification element
    const notification = document.createElement('div')
    notification.className = 'fixed bottom-4 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg text-sm z-50 animate-fade-in'
    notification.textContent = message
    
    // Add to DOM
    document.body.appendChild(notification)
    
    // Remove after 2 seconds
    setTimeout(() => {
      notification.classList.add('opacity-0', 'transition-opacity', 'duration-300')
      setTimeout(() => notification.remove(), 300)
    }, 2000)
  }
}
