import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  
  connect() {
    this.debounceTimer = null
    this.minSearchLength = 2
  }
  
  debounceSearch() {
    clearTimeout(this.debounceTimer)
    
    // Set a delay before performing search
    this.debounceTimer = setTimeout(() => {
      const query = this.inputTarget.value.trim()
      
      if (query.length >= this.minSearchLength) {
        this.performSearch(query)
      } else if (query.length === 0) {
        this.clearResults()
      }
    }, 300) // 300ms debounce delay
  }
  
  search(event) {
    event.preventDefault()
    const query = this.inputTarget.value.trim()
    
    if (query.length >= this.minSearchLength) {
      this.performSearch(query)
    }
  }
  
  performSearch(query) {
    // Show loading state
    this.resultsTarget.innerHTML = `
      <div class="flex justify-center py-8">
        <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      </div>
    `
    
    // Fetch search results
    fetch(`/products/search?query=${encodeURIComponent(query)}`, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      if (html.trim()) {
        Turbo.renderStreamMessage(html)
      } else {
        this.showNoResults()
      }
    })
    .catch(error => {
      console.error('Search error:', error)
      this.showError()
    })
  }
  
  clearResults() {
    this.resultsTarget.innerHTML = ''
  }
  
  showNoResults() {
    this.resultsTarget.innerHTML = `
      <div class="text-center py-8">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <h3 class="mt-2 text-lg font-medium text-gray-900">No results found</h3>
        <p class="mt-1 text-sm text-gray-500">Try adjusting your search or filter to find what you're looking for.</p>
      </div>
    `
  }
  
  showError() {
    this.resultsTarget.innerHTML = `
      <div class="text-center py-8">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <h3 class="mt-2 text-lg font-medium text-gray-900">Search error</h3>
        <p class="mt-1 text-sm text-gray-500">An error occurred while searching. Please try again.</p>
      </div>
    `
  }
}