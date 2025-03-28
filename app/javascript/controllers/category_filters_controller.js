  import { Controller } from "@hotwired/stimulus"
  
  export default class extends Controller {
    static targets = ["panel", "count"]
    
    connect() {
      // Initialize filter count
      this.updateFilterCount()
    }
    
    toggleFilters() {
      if (this.panelTarget.classList.contains('max-h-0')) {
        this.panelTarget.classList.remove('max-h-0')
        this.panelTarget.classList.add('max-h-[800px]')
      } else {
        this.panelTarget.classList.remove('max-h-[800px]')
        this.panelTarget.classList.add('max-h-0')
      }
    }
    
    clearAll() {
      // Reset all checkboxes and inputs
      this.element.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false
      })
      
      // Reset price range
      const minPrice = this.element.querySelector('input[value="50"]')
      const maxPrice = this.element.querySelector('input[value="500"]')
      if (minPrice) minPrice.value = "0"
      if (maxPrice) maxPrice.value = "1000"
      
      this.updateFilterCount()
    }
    
    applyFilters() {
      // In a real app, this would submit the form or update via Turbo
      this.toggleFilters()
      
      // For demo, just update the count
      this.updateFilterCount()
    }
    
    updateFilterCount() {
      const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked').length
      this.countTarget.textContent = checkedBoxes
    }
  }