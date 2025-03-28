import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]
  
  togglePanel(filterType) {
    this.panelTargets.forEach(panel => {
      if (panel.dataset.id === filterType) {
        panel.classList.toggle('hidden')
      } else {
        panel.classList.add('hidden')
      }
    })
  }
  
  hidePanel(event) {
    const panel = event.currentTarget.closest('[data-filter-panels-target="panel"]')
    panel.classList.add('hidden')
  }
}
