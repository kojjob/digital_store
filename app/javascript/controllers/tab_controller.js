class TabsController extends Controller {
  static targets = ["tab", "panel"]
  
  connect() {
    // Default to first tab being active
  }
  
  switchTab(event) {
    const selectedIndex = parseInt(event.currentTarget.dataset.index)
    
    // Update tab states
    this.tabTargets.forEach((tab, index) => {
      if (index === selectedIndex) {
        tab.classList.add('border-indigo-600', 'text-indigo-600')
        tab.classList.remove('border-transparent', 'text-gray-500')
      } else {
        tab.classList.remove('border-indigo-600', 'text-indigo-600')
        tab.classList.add('border-transparent', 'text-gray-500')
      }
    })
    
    // Update panel visibility
    this.panelTargets.forEach((panel, index) => {
      if (index === selectedIndex) {
        panel.classList.remove('hidden')
      } else {
        panel.classList.add('hidden')
      }
    })
  }
}