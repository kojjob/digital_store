import { Controller } from "@hotwired/stimulus"

/**
 * Mobile Menu Controller
 *
 * Manages the mobile menu functionality for the dashboard.
 * This follows the principles of separation of concerns by isolating
 * the menu toggle behavior in its own controller.
 */
export default class extends Controller {
  static targets = ["menu"]

  /**
   * Connect lifecycle method
   * Called when the controller is connected to the DOM
   */
  connect() {
    // Listen for escape key to close menu
    document.addEventListener("keydown", this.handleKeyDown.bind(this))
    
    // Listen for resize events to handle responsive behavior
    window.addEventListener("resize", this.handleResize.bind(this))
    
    console.log("Mobile menu controller connected")
  }

  /**
   * Disconnect lifecycle method
   * Called when the controller is disconnected from the DOM
   */
  disconnect() {
    document.removeEventListener("keydown", this.handleKeyDown.bind(this))
    window.removeEventListener("resize", this.handleResize.bind(this))
  }

  /**
   * Toggle the mobile menu visibility
   */
  toggle() {
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  /**
   * Open the mobile menu
   */
  open() {
    this.menuTarget.style.display = "flex"
    
    // Add a class to the body to prevent scrolling
    document.body.classList.add("overflow-hidden")
    
    // Set ARIA attributes
    this.menuTarget.setAttribute("aria-expanded", "true")
  }

  /**
   * Close the mobile menu
   */
  close() {
    this.menuTarget.style.display = "none"
    
    // Remove the class from the body to allow scrolling
    document.body.classList.remove("overflow-hidden")
    
    // Set ARIA attributes
    this.menuTarget.setAttribute("aria-expanded", "false")
  }

  /**
   * Check if the menu is currently open
   * @returns {boolean} True if the menu is open
   */
  isOpen() {
    return this.menuTarget.style.display === "flex"
  }

  /**
   * Handle keydown events
   * Close the menu when the escape key is pressed
   * @param {Event} event - The keydown event
   */
  handleKeyDown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.close()
    }
  }

  /**
   * Handle window resize events
   * Close the mobile menu when the window is resized to desktop dimensions
   */
  handleResize() {
    if (window.innerWidth >= 768 && this.isOpen()) {
      // 768px is the md breakpoint in Tailwind
      this.close()
    }
  }
}
