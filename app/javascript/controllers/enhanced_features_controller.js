import { Controller } from "@hotwired/stimulus"

/**
 * Enhanced Features Controller
 * 
 * Handles various enhanced UI elements for the product page:
 * - Image zoom functionality
 * - Social sharing
 * - Size and color variant selection
 * - Recently viewed products with localStorage
 * - Size guide modal
 */
export default class extends Controller {
  static targets = [
    "mainImage", "zoomModal", "zoomedImage", 
    "colorButton", "sizeButton", "sizeGuideModal",
    "recentlyViewedContainer", "stickyCart",
    "priceBadge", "stockIndicator", "quantity"
  ]

  static values = {
    productId: String,
    productName: String,
    productImage: String,
    productPrice: String,
    productUrl: String,
    stockQuantity: Number
  }

  connect() {
    this._initRecentlyViewed()
    this._observeScroll()
    
    // Initialize with default selected state
    if (this.hasColorButtonTargets && this.colorButtonTargets.length > 0) {
      this.colorButtonTargets[0].classList.add('ring-2', 'ring-offset-2', 'ring-green-500')
    }
    
    if (this.hasSizeButtonTargets && this.sizeButtonTargets.length > 0) {
      // Default select M (index 1)
      const defaultSizeIndex = 1
      if (this.sizeButtonTargets[defaultSizeIndex]) {
        this.sizeButtonTargets[defaultSizeIndex].classList.add('border-green-500', 'bg-green-50', 'text-green-700')
        this.sizeButtonTargets[defaultSizeIndex].classList.remove('border-gray-200', 'text-gray-900', 'hover:bg-gray-50')
      }
    }
  }

  // Image zoom handling
  openZoom(event) {
    if (!this.hasZoomModalTarget || !this.hasZoomedImageTarget) return
    
    const img = event.currentTarget.querySelector('img')
    if (img) {
      this.zoomedImageTarget.src = img.src
      this.zoomModalTarget.classList.remove('hidden')
      document.body.classList.add('overflow-hidden')
    }
  }

  closeZoom() {
    if (!this.hasZoomModalTarget) return
    
    this.zoomModalTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
  }

  // Color and size variant selection
  selectColor(event) {
    if (!this.hasColorButtonTargets) return
    
    // Remove selected state from all buttons
    this.colorButtonTargets.forEach(btn => {
      btn.classList.remove('ring-2', 'ring-offset-2', 'ring-green-500')
      const checkmark = btn.querySelector('.absolute')
      if (checkmark) checkmark.remove()
    })
    
    // Add selected state to clicked button
    const button = event.currentTarget
    button.classList.add('ring-2', 'ring-offset-2', 'ring-green-500')
    
    // Add checkmark if not exists
    if (!button.querySelector('.absolute')) {
      const checkmark = document.createElement('span')
      checkmark.className = 'absolute -right-1 -top-1 h-5 w-5 rounded-full bg-green-600 flex items-center justify-center'
      checkmark.innerHTML = '<svg class="h-3 w-3 text-white" fill="currentColor" viewBox="0 0 24 24"><path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z"/></svg>'
      button.appendChild(checkmark)
    }
  }

  selectSize(event) {
    if (!this.hasSizeButtonTargets) return
    
    // Remove selected state from all buttons
    this.sizeButtonTargets.forEach(btn => {
      btn.classList.remove('border-green-500', 'bg-green-50', 'text-green-700')
      btn.classList.add('border-gray-200', 'text-gray-900', 'hover:bg-gray-50')
    })
    
    // Add selected state to clicked button
    const button = event.currentTarget
    button.classList.remove('border-gray-200', 'text-gray-900', 'hover:bg-gray-50')
    button.classList.add('border-green-500', 'bg-green-50', 'text-green-700')
  }

  openSizeGuide() {
    if (!this.hasSizeGuideModalTarget) return
    
    this.sizeGuideModalTarget.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
  }

  closeSizeGuide() {
    if (!this.hasSizeGuideModalTarget) return
    
    this.sizeGuideModalTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
  }

  // Social sharing functionality
  shareWhatsApp() {
    const text = `Check out ${this.productNameValue}: ${window.location.href}`
    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`)
  }

  shareFacebook() {
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(window.location.href)}`)
  }

  shareTwitter() {
    const text = `Check out ${this.productNameValue}`
    window.open(`https://twitter.com/intent/tweet?url=${encodeURIComponent(window.location.href)}&text=${encodeURIComponent(text)}`)
  }

  copyLink() {
    navigator.clipboard.writeText(window.location.href).then(() => {
      this._showNotification('Link copied to clipboard!')
    }).catch(err => {
      console.error('Could not copy link: ', err)
    })
  }

  // Quantity control
  increase() {
    if (!this.hasQuantityTarget) return
    
    const max = this.stockQuantityValue || parseInt(this.quantityTarget.max)
    const current = parseInt(this.quantityTarget.value)
    
    if (current < max) {
      this.quantityTarget.value = current + 1
      this._updateQuantityOutputs()
    }
  }

  decrease() {
    if (!this.hasQuantityTarget) return
    
    const current = parseInt(this.quantityTarget.value)
    
    if (current > 1) {
      this.quantityTarget.value = current - 1
      this._updateQuantityOutputs()
    }
  }

  // Recently viewed products handling
  _initRecentlyViewed() {
    if (!this.hasRecentlyViewedContainerTarget) return
    if (!this.productIdValue) return
    
    // Store current product in recently viewed
    let recentlyViewed = JSON.parse(localStorage.getItem('recentlyViewedProducts') || '[]')
    
    // Only add if not already in the list
    if (!recentlyViewed.some(p => p.id === this.productIdValue)) {
      // Add current product to the beginning of the array
      recentlyViewed.unshift({
        id: this.productIdValue,
        name: this.productNameValue,
        image: this.productImageValue,
        price: this.productPriceValue,
        url: window.location.pathname,
        viewedAt: new Date().toISOString()
      })
      
      // Keep only the last 6 items
      recentlyViewed = recentlyViewed.slice(0, 6)
      
      // Save back to localStorage
      localStorage.setItem('recentlyViewedProducts', JSON.stringify(recentlyViewed))
    }
    
    // Display recently viewed products
    this._displayRecentlyViewed(recentlyViewed)
  }

  _displayRecentlyViewed(recentlyViewed) {
    if (!this.hasRecentlyViewedContainerTarget) return
    if (!this.productIdValue) return
    
    // Only show other products (not the current one)
    const otherProducts = recentlyViewed.filter(p => p.id !== this.productIdValue)
    
    if (otherProducts.length === 0) {
      // Show placeholder if no other recently viewed products
      this.recentlyViewedContainerTarget.innerHTML = `
        <div class="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-300 group transform hover:-translate-y-1 flex items-center justify-center h-40 text-gray-400 text-sm">
          <p>Browse more products to see your history</p>
        </div>
      `
      return
    }
    
    // Clear container
    this.recentlyViewedContainerTarget.innerHTML = ''
    
    // Add products except the current one
    otherProducts.forEach(product => {
      const productCard = document.createElement('div')
      productCard.className = 'bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-300 group transform hover:-translate-y-1'
      
      let imageHtml = ''
      if (product.image) {
        imageHtml = `<img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover">`
      } else {
        imageHtml = `<div class="flex h-full w-full items-center justify-center bg-gray-200">
          <svg class="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        </div>`
      }
      
      productCard.innerHTML = `
        <a href="${product.url}" class="block">
          <div class="aspect-w-1 aspect-h-1 bg-gray-200 relative">
            ${imageHtml}
            <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-2">
              <p class="text-white text-xs font-medium truncate">${product.name}</p>
            </div>
          </div>
        </a>
      `
      
      this.recentlyViewedContainerTarget.appendChild(productCard)
    })
  }

  // Sticky cart functionality
  _observeScroll() {
    if (!this.hasStickyCartTarget) return
    
    let lastScrollTop = 0
    
    window.addEventListener('scroll', () => {
      const st = window.pageYOffset || document.documentElement.scrollTop
      
      if (st > 300) {
        if (st > lastScrollTop) {
          // Scrolling down - hide the bar
          this.stickyCartTarget.classList.remove('translate-y-0')
          this.stickyCartTarget.classList.add('translate-y-full')
        } else {
          // Scrolling up - show the bar
          this.stickyCartTarget.classList.remove('translate-y-full')
          this.stickyCartTarget.classList.add('translate-y-0')
        }
      } else {
        // At the top - hide the bar
        this.stickyCartTarget.classList.remove('translate-y-0')
        this.stickyCartTarget.classList.add('translate-y-full')
      }
      
      lastScrollTop = st <= 0 ? 0 : st
    })
  }

  // Helper function to update hidden quantity fields
  _updateQuantityOutputs() {
    if (!this.hasQuantityTarget) return
    
    // Update any output fields that need the quantity value
    const quantity = this.quantityTarget.value
    const outputs = document.querySelectorAll('[data-product-quantity-target="outputField"]')
    
    outputs.forEach(output => {
      output.value = quantity
    })
  }

  // Helper to show notifications
  _showNotification(message) {
    const notification = document.createElement('div')
    notification.className = 'fixed bottom-4 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg text-sm z-50'
    notification.textContent = message
    document.body.appendChild(notification)
    
    // Remove notification after 2 seconds
    setTimeout(() => {
      notification.remove()
    }, 2000)
  }
}
