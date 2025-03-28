import { Controller } from "@hotwired/stimulus"

class ProductGalleryController extends Controller {
  static targets = ["mainImage", "mainImageContainer", "thumbnail"]
  
  connect() {
    // Initialize gallery
  }
  
  changeImage(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    const imageUrl = event.currentTarget.querySelector('img').src
    
    // Update main image
    this.mainImageTarget.querySelector('img').src = imageUrl
    
    // Update selected thumbnail
    this.thumbnailTargets.forEach((thumb, i) => {
      if (i === index) {
        thumb.classList.add('border-indigo-600')
        thumb.classList.remove('border-transparent')
      } else {
        thumb.classList.remove('border-indigo-600')
        thumb.classList.add('border-transparent')
      }
    })
    
    // Add a subtle fade transition
    this.mainImageTarget.classList.add('opacity-0')
    setTimeout(() => {
      this.mainImageTarget.classList.remove('opacity-0')
    }, 50)
  }
}




