import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    productId: String,
    productName: String,
    productImage: String,
    productPrice: String,
    productUrl: String,
    maxItems: { type: Number, default: 6 }
  }
  
  connect() {
    // Set default product URL if not provided
    if (!this.hasProductUrlValue) {
      this.productUrlValue = window.location.pathname
    }
    
    // Add current product to recently viewed
    this.addToRecentlyViewed()
    
    // Display recently viewed products
    this.displayRecentlyViewed()
  }
  
  addToRecentlyViewed() {
    if (!this.hasProductIdValue) return
    
    // Get existing recently viewed products
    let recentlyViewed = this.getRecentlyViewed()
    
    // Check if this product is already in the list
    const existingIndex = recentlyViewed.findIndex(p => p.id === this.productIdValue)
    
    // If exists, remove it so we can add it to the beginning
    if (existingIndex !== -1) {
      recentlyViewed.splice(existingIndex, 1)
    }
    
    // Add current product to the beginning
    recentlyViewed.unshift({
      id: this.productIdValue,
      name: this.productNameValue || document.title,
      image: this.productImageValue || '',
      price: this.productPriceValue || '',
      url: this.productUrlValue,
      viewedAt: new Date().toISOString()
    })
    
    // Keep only the latest N items
    recentlyViewed = recentlyViewed.slice(0, this.maxItemsValue)
    
    // Save back to localStorage
    localStorage.setItem('recentlyViewedProducts', JSON.stringify(recentlyViewed))
  }
  
  displayRecentlyViewed() {
    if (!this.hasContainerTarget) return
    
    // Get recently viewed products
    const recentlyViewed = this.getRecentlyViewed()
    
    // Display only if there are other products besides the current one
    const otherProducts = recentlyViewed.filter(p => p.id !== this.productIdValue)
    
    if (otherProducts.length > 0) {
      // Clear container
      this.containerTarget.innerHTML = ''
      
      // Add products to container
      otherProducts.forEach(product => {
        const productCard = this.createProductCard(product)
        this.containerTarget.appendChild(productCard)
      })
    } else {
      // Show placeholder when no other products
      this.containerTarget.innerHTML = `
        <div class="bg-white rounded-lg shadow-sm overflow-hidden flex items-center justify-center h-40 text-gray-400 text-sm">
          <p>Browse more products to see your history</p>
        </div>
      `
    }
  }
  
  createProductCard(product) {
    const div = document.createElement('div')
    div.className = 'bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-300 group transform hover:-translate-y-1'
    
    // Create image HTML
    let imageHtml = ''
    if (product.image) {
      imageHtml = `<img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">`
    } else {
      imageHtml = `
        <div class="flex h-full w-full items-center justify-center bg-gray-200">
          <svg class="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        </div>
      `
    }
    
    // Create price HTML
    let priceHtml = ''
    if (product.price) {
      priceHtml = `<p class="text-xs font-medium text-green-600">${product.price}</p>`
    }
    
    // Set card inner HTML
    div.innerHTML = `
      <a href="${product.url}" class="block">
        <div class="aspect-w-1 aspect-h-1 bg-gray-200 relative">
          ${imageHtml}
          <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-2">
            <p class="text-white text-xs font-medium truncate">${product.name}</p>
            ${priceHtml}
          </div>
        </div>
      </a>
    `
    
    return div
  }
  
  getRecentlyViewed() {
    try {
      return JSON.parse(localStorage.getItem('recentlyViewedProducts') || '[]')
    } catch (e) {
      console.error('Error reading recently viewed products:', e)
      return []
    }
  }
}
