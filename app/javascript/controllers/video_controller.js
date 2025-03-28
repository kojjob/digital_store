import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  play(event) {
    // In a real implementation, this would play a video
    // For now, we'll just change the button appearance
    const button = event.currentTarget
    button.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-white" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8 9a1 1 0 011-1h2a1 1 0 110 2H9a1 1 0 01-1-1z" clip-rule="evenodd" />
      </svg>
    `
    
    // Create a video player
    const videoContainer = button.closest('.aspect-video')
    const video = document.createElement('video')
    video.src = "https://example.com/company_video.mp4" // This would be a real video URL
    video.classList.add('absolute', 'inset-0', 'w-full', 'h-full', 'object-cover')
    video.setAttribute('controls', '')
    video.setAttribute('autoplay', '')
    
    // In a real implementation, we would insert the video
    // For this example, we'll just update the UI feedback
    button.classList.add('opacity-50')
    
    // Prevent default behavior
    event.preventDefault()
  }
}