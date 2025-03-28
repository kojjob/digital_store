import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["colorOption", "sizeOption", "variantId", "price", "comparePrice", "stock", "form", "addButton"]
  static values = {
    variants: Array,
    selected: Object
  }
  
  connect() {
    // Set initial selected variant if available
    if (this.variantIdTarget && this.hasVariantsValue && this.variantsValue.length > 0) {
      this.selectedValue = this.variantsValue[0]
      this.variantIdTarget.value = this.selectedValue.id
      this.updateUI()
    }
    
    // Check initial stock status
    this.checkStockStatus()
  }
  
  selectColor(event) {
    const color = event.currentTarget.dataset.productVariantsColorParam
    
    // Update UI for selected color
    this.colorOptionTargets.forEach(option => {
      const isSelected = option.dataset.productVariantsColorParam === color
      option.classList.toggle('ring-2', isSelected)
      option.classList.toggle('ring-offset-2', isSelected)
      option.classList.toggle('ring-green-500', isSelected)
      
      // Update checkmark indicator
      const checkmark = option.querySelector('.absolute')
      if (checkmark) checkmark.remove()
      
      if (isSelected) {
        const checkmark = document.createElement('span')
        checkmark.className = 'absolute -right-1 -top-1 h-5 w-5 rounded-full bg-green-600 flex items-center justify-center'
        checkmark.innerHTML = '<svg class="h-3 w-3 text-white" fill="currentColor" viewBox="0 0 24 24"><path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z"/></svg>'
        option.appendChild(checkmark)
      }
    })
    
    // Find matching variant and update selection
    this.updateSelectedVariant()
  }
  
  selectSize(event) {
    const size = event.currentTarget.dataset.productVariantsSizeParam
    
    // Update UI for selected size
    this.sizeOptionTargets.forEach(option => {
      const isSelected = option.dataset.productVariantsSizeParam === size
      option.classList.toggle('border-green-500', isSelected)
      option.classList.toggle('bg-green-50', isSelected)
      option.classList.toggle('text-green-700', isSelected)
      option.classList.toggle('border-gray-200', !isSelected)
      option.classList.toggle('text-gray-900', !isSelected)
      option.classList.toggle('hover:bg-gray-50', !isSelected)
    })
    
    // Find matching variant and update selection
    this.updateSelectedVariant()
  }
  
  updateSelectedVariant() {
    if (!this.hasVariantsValue) return
    
    // Get currently selected color and size
    const selectedColor = this.colorOptionTargets.find(target => 
      target.classList.contains('ring-2')
    )?.dataset.productVariantsColorParam
    
    const selectedSize = this.sizeOptionTargets.find(target => 
      target.classList.contains('border-green-500')
    )?.dataset.productVariantsSizeParam
    
    // Find matching variant
    const matchingVariant = this.variantsValue.find(variant => 
      (!selectedColor || variant.color === selectedColor) && 
      (!selectedSize || variant.size === selectedSize)
    )
    
    if (matchingVariant) {
      this.selectedValue = matchingVariant
      if (this.hasVariantIdTarget) {
        this.variantIdTarget.value = matchingVariant.id
      }
      this.updateUI()
    }
  }
  
  updateUI() {
    // Update price
    if (this.hasPriceTarget && this.selectedValue) {
      const formatted = new Intl.NumberFormat('en', { 
        style: 'currency', 
        currency: this.selectedValue.currency || 'USD' 
      }).format(this.selectedValue.price)
      
      this.priceTarget.textContent = formatted
    }
    
    // Update compare price if discounted
    if (this.hasComparePriceTarget && this.selectedValue) {
      if (this.selectedValue.comparePrice && this.selectedValue.comparePrice > this.selectedValue.price) {
        const formatted = new Intl.NumberFormat('en', { 
          style: 'currency', 
          currency: this.selectedValue.currency || 'USD' 
        }).format(this.selectedValue.comparePrice)
        
        this.comparePriceTarget.textContent = formatted
        this.comparePriceTarget.classList.remove('hidden')
      } else {
        this.comparePriceTarget.classList.add('hidden')
      }
    }
    
    // Update stock status
    if (this.hasStockTarget && this.selectedValue) {
      this.stockTarget.textContent = this.selectedValue.stock > 0 
        ? `In Stock (${this.selectedValue.stock} available)` 
        : 'Out of Stock'
        
      this.stockTarget.classList.toggle('text-green-700', this.selectedValue.stock > 0)
      this.stockTarget.classList.toggle('text-red-700', this.selectedValue.stock <= 0)
    }
    
    this.checkStockStatus()
  }
  
  checkStockStatus() {
    // Disable add button if out of stock
    if (this.hasAddButtonTarget && this.selectedValue) {
      const isOutOfStock = this.selectedValue.stock <= 0
      this.addButtonTarget.disabled = isOutOfStock
      this.addButtonTarget.classList.toggle('opacity-50', isOutOfStock)
      this.addButtonTarget.classList.toggle('cursor-not-allowed', isOutOfStock)
      
      if (isOutOfStock) {
        this.addButtonTarget.textContent = 'Out of Stock'
      } else {
        this.addButtonTarget.textContent = 'Add to Cart'
      }
    }
  }
  
  openSizeChart(event) {
    event.preventDefault()
    const sizeChartModal = document.getElementById('sizeGuideModal')
    if (sizeChartModal) {
      sizeChartModal.classList.remove('hidden')
      document.body.classList.add('overflow-hidden')
    }
  }
}
