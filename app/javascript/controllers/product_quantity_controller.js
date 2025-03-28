class ProductQuantityController extends Controller {
  static targets = ["input", "outputField"]
  
  connect() {
    this.updateOutputField()
  }
  
  increase() {
    const max = parseInt(this.inputTarget.max)
    const current = parseInt(this.inputTarget.value)
    
    if (current < max) {
      this.inputTarget.value = current + 1
      this.updateOutputField()
    }
  }
  
  decrease() {
    const current = parseInt(this.inputTarget.value)
    
    if (current > 1) {
      this.inputTarget.value = current - 1
      this.updateOutputField()
    }
  }
  
  updateOutputField() {
    if (this.hasOutputFieldTarget) {
      this.outputFieldTarget.value = this.inputTarget.value
    }
  }
}