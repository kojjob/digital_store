import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    // Set min length for search
    this.minLength = 2
    
    // Debounce the search to avoid too many requests
    this.debounceTimeout = null
    this.debounceMs = 300
  }
  
  search() {
    clearTimeout(this.debounceTimeout)
    
    const query = this.inputTarget.value.trim()
    
    // Hide results if query is too short
    if (query.length < this.minLength) {
      this.hideResults()
      return
    }
    
    // Debounce the search
    this.debounceTimeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceMs)
  }
  
  async performSearch(query) {
    try {
      // Show loading state
      this.showLoading()
      
      // Make the request
      const response = await fetch(`/search?query=${encodeURIComponent(query)}&format=json`)
      
      if (!response.ok) {
        throw new Error(`Search request failed: ${response.status}`)
      }
      
      const data = await response.json()
      
      // Render results
      this.renderResults(data, query)
      
    } catch (error) {
      console.error('Search error:', error)
      this.showError(error.message)
    }
  }
  
  renderResults(data, query) {
    if (!this.hasResultsTarget) return
    
    // Clear previous results
    this.resultsTarget.innerHTML = ''
    
    // If no results
    if (data.results.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="py-4 px-4 text-sm text-gray-700 text-center">
          No results found for "${query}"
        </div>
      `
      this.showResults()
      return
    }
    
    // Create results HTML
    let resultsHtml = ''
    
    // Add categories
    if (data.categories && data.categories.length > 0) {
      resultsHtml += `
        <div class="p-2 text-xs font-semibold text-gray-500 bg-gray-50">
          Categories
        </div>
      `
      
      data.categories.forEach(category => {
        resultsHtml += `
          <a href="/products?category_id=${category.id}" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 flex items-center">
            <svg class="w-4 h-4 mr-2 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
            ${category.name}
          </a>
        `
      })
    }
    
    // Add products
    if (data.products && data.products.length > 0) {
      resultsHtml += `
        <div class="p-2 text-xs font-semibold text-gray-500 bg-gray-50">
          Products
        </div>
      `
      
      data.products.forEach(product => {
        const image = product.image_url || '/images/placeholder-product.png'
        resultsHtml += `
          <a href="/products/${product.id}" class="block px-4 py-2 hover:bg-gray-100">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-gray-100 rounded overflow-hidden flex-shrink-0">
                <img src="${image}" alt="${product.name}" class="w-full h-full object-cover">
              </div>
              <div class="ml-3 flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900 truncate">${product.name}</p>
                <p class="text-xs text-gray-500 truncate">${product.category_name || ''}</p>
              </div>
              <div class="text-sm font-semibold text-indigo-600">
                ${product.currency || '$'}${product.price}
              </div>
            </div>
          </a>
        `
      })
    }
    
    // Add view all results link
    resultsHtml += `
      <div class="px-4 py-2 border-t border-gray-100">
        <a href="/search?query=${encodeURIComponent(query)}" class="text-sm text-indigo-600 hover:text-indigo-800 flex items-center justify-center">
          View all results
          <svg class="ml-1 w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
          </svg>
        </a>
      </div>
    `
    
    this.resultsTarget.innerHTML = resultsHtml
    this.showResults()
  }
  
  showLoading() {
    if (!this.hasResultsTarget) return
    
    this.resultsTarget.innerHTML = `
      <div class="flex justify-center items-center p-4">
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-indigo-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span class="text-sm text-gray-500">Searching...</span>
      </div>
    `
    
    this.showResults()
  }
  
  showError(message) {
    if (!this.hasResultsTarget) return
    
    this.resultsTarget.innerHTML = `
      <div class="py-4 px-4 text-sm text-red-500 text-center">
        ${message}
      </div>
    `
    
    this.showResults()
  }
  
  showResults() {
    if (!this.hasResultsTarget) return
    this.resultsTarget.classList.remove('hidden')
  }
  
  hideResults() {
    if (!this.hasResultsTarget) return
    this.resultsTarget.classList.add('hidden')
  }
  
  // Handle clicking outside to close results
  clickOutside(event) {
    if (!this.element.contains(event.target) && !this.resultsTarget.classList.contains('hidden')) {
      this.hideResults()
    }
  }
}
