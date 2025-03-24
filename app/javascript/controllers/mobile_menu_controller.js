import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]
  
  connect() {
    // Close menu when clicking on a link in mobile menu
    this.menuTarget.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => this.hide())
    })
    
    // Close menu when escape key is pressed
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.hide()
    }
  }
  
  toggle() {
    if (this.menuTarget.classList.contains('max-h-0')) {
      this.show()
    } else {
      this.hide()
    }
  }
  
  show() {
    this.openIconTarget.classList.add('hidden')
    this.closeIconTarget.classList.remove('hidden')
    
    // Measure the height of the menu content to animate it properly
    this.menuTarget.classList.replace('max-h-0', 'max-h-screen')
    const height = this.menuTarget.scrollHeight
    this.menuTarget.style.maxHeight = '0px'
    
    // Trigger animation
    setTimeout(() => {
      this.menuTarget.style.maxHeight = `${height}px`
    }, 10)
    
    // Add body scroll lock
    document.body.classList.add('overflow-hidden', 'md:overflow-auto')
  }
  
  hide() {
    this.closeIconTarget.classList.add('hidden')
    this.openIconTarget.classList.remove('hidden')
    
    // Animate closing
    this.menuTarget.style.maxHeight = '0px'
    
    // Reset class after animation completes
    setTimeout(() => {
      this.menuTarget.classList.replace('max-h-screen', 'max-h-0')
      this.menuTarget.style.maxHeight = ''
    }, 300)
    
    // Remove body scroll lock
    document.body.classList.remove('overflow-hidden')
  }
}