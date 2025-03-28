import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "content", "icon"]
  
  connect() {
    // Initialize all items as closed
    this.contentTargets.forEach(content => {
      content.style.maxHeight = "0px"
    })
    
    // Optional: open the first item by default
    this.open(0)
  }
  
  toggle(event) {
    const item = event.currentTarget.closest('[data-accordion-target="item"]')
    const index = parseInt(item.dataset.index)
    
    // Get the current state
    const content = this.contentTargets[index]
    const isOpen = content.style.maxHeight !== "0px"
    
    // Close if open, open if closed
    if (isOpen) {
      this.close(index)
    } else {
      this.open(index)
    }
  }
  
  open(index) {
    const content = this.contentTargets[index]
    const icon = this.iconTargets[index]
    
    // Set max-height to the scroll height for smooth animation
    content.style.maxHeight = `${content.scrollHeight}px`
    icon.style.transform = "rotate(180deg)"
  }
  
  close(index) {
    const content = this.contentTargets[index]
    const icon = this.iconTargets[index]
    
    content.style.maxHeight = "0px"
    icon.style.transform = "rotate(0deg)"
  }
}