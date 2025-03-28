class ImageZoomController extends Controller {
  static targets = ["zoomable", "instructions"]
  
  connect() {
    if (this.hasZoomableTarget) {
      this.zoomableTarget.addEventListener('mousemove', this.zoom.bind(this))
      this.zoomableTarget.addEventListener('mouseenter', this.showInstructions.bind(this))
      this.zoomableTarget.addEventListener('mouseleave', this.resetZoom.bind(this))
    }
  }
  
  disconnect() {
    if (this.hasZoomableTarget) {
      this.zoomableTarget.removeEventListener('mousemove', this.zoom.bind(this))
      this.zoomableTarget.removeEventListener('mouseenter', this.showInstructions.bind(this))
      this.zoomableTarget.removeEventListener('mouseleave', this.resetZoom.bind(this))
    }
  }
  
  showInstructions() {
    if (this.hasInstructionsTarget) {
      this.instructionsTarget.classList.add('opacity-100')
      setTimeout(() => {
        this.instructionsTarget.classList.remove('opacity-100')
      }, 2000)
    }
  }
  
  zoom(event) {
    const image = this.zoomableTarget.querySelector('img')
    const { left, top, width, height } = this.zoomableTarget.getBoundingClientRect()
    const x = (event.clientX - left) / width
    const y = (event.clientY - top) / height
    
    // Scale and position the image for zoom effect
    image.style.transformOrigin = `${x * 100}% ${y * 100}%`
    image.style.transform = 'scale(1.5)'
  }
  
  resetZoom() {
    const image = this.zoomableTarget.querySelector('img')
    image.style.transform = 'scale(1)'
  }
}