import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["gridView", "listView"]
  
  connect() {
    // Default to grid view
    this.showGrid()
  }
  
  switchToGrid() {
    this.showGrid()
  }
  
  switchToList() {
    this.showList()
  }
  
  showGrid() {
    this.gridViewTarget.classList.remove('hidden')
    this.listViewTarget.classList.add('hidden')
  }
  
  showList() {
    this.gridViewTarget.classList.add('hidden')
    this.listViewTarget.classList.remove('hidden')
  }
}

