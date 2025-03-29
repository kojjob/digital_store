import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = [
    "platformActivityChart", 
    "revenueChart", 
    "tab", 
    "tabContent", 
    "sidebar",
    "sidebarToggle"
  ]

  connect() {
    console.log("Dashboard controller connected")
    this.initializeCharts()
    
    // Set default tab on connect
    if (this.hasTabTarget) {
      // Delay it slightly to ensure everything is rendered
      setTimeout(() => this.showTab("overview"), 100)
    }
  }

  initializeCharts() {
    if (this.hasPlatformActivityChartTarget) {
      this.initializePlatformActivityChart()
    }
    
    if (this.hasRevenueChartTarget) {
      this.initializeRevenueChart()
    }
  }

  initializePlatformActivityChart() {
    const ctx = this.platformActivityChartTarget.getContext('2d')
    const chartMonths = JSON.parse(this.platformActivityChartTarget.getAttribute('data-months') || '[]')
    const userData = JSON.parse(this.platformActivityChartTarget.getAttribute('data-users') || '[]')
    const orderData = JSON.parse(this.platformActivityChartTarget.getAttribute('data-orders') || '[]')
    
    // Create gradients
    const activityChartGradient = ctx.createLinearGradient(0, 0, 0, 400)
    activityChartGradient.addColorStop(0, 'rgba(79, 70, 229, 0.6)')
    activityChartGradient.addColorStop(1, 'rgba(79, 70, 229, 0.1)')
    
    const orderGradient = ctx.createLinearGradient(0, 0, 0, 400)
    orderGradient.addColorStop(0, 'rgba(239, 68, 68, 0.6)')
    orderGradient.addColorStop(1, 'rgba(239, 68, 68, 0.1)')
    
    // Create chart
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: chartMonths,
        datasets: [{
          label: 'New Users',
          data: userData,
          backgroundColor: activityChartGradient,
          borderColor: 'rgba(79, 70, 229, 1)',
          borderWidth: 2,
          tension: 0.4,
          fill: true,
          pointBackgroundColor: '#fff',
          pointBorderColor: 'rgba(79, 70, 229, 1)',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6
        }, {
          label: 'Orders',
          data: orderData,
          backgroundColor: orderGradient,
          borderColor: 'rgba(239, 68, 68, 1)',
          borderWidth: 2,
          tension: 0.4,
          fill: true,
          pointBackgroundColor: '#fff',
          pointBorderColor: 'rgba(239, 68, 68, 1)',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: 'index',
        },
        plugins: {
          legend: {
            position: 'top',
            labels: {
              boxWidth: 12,
              usePointStyle: true,
              pointStyle: 'circle'
            }
          },
          tooltip: {
            usePointStyle: true,
            backgroundColor: 'rgba(255, 255, 255, 0.9)',
            titleColor: '#111827',
            bodyColor: '#111827',
            borderColor: 'rgba(226, 232, 240, 1)',
            borderWidth: 1,
            padding: 12,
            boxPadding: 6
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            },
            grid: {
              color: 'rgba(226, 232, 240, 0.5)'
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        }
      }
    })
  }

  initializeRevenueChart() {
    const ctx = this.revenueChartTarget.getContext('2d')
    const chartMonths = JSON.parse(this.revenueChartTarget.getAttribute('data-months') || '[]')
    const revenueData = JSON.parse(this.revenueChartTarget.getAttribute('data-revenue') || '[]')
    
    // Create gradient
    const revenueGradient = ctx.createLinearGradient(0, 0, 0, 400)
    revenueGradient.addColorStop(0, 'rgba(16, 185, 129, 0.8)')
    revenueGradient.addColorStop(1, 'rgba(16, 185, 129, 0.2)')
    
    // Create chart
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: chartMonths,
        datasets: [{
          label: 'Revenue',
          data: revenueData,
          backgroundColor: revenueGradient,
          borderColor: 'rgba(16, 185, 129, 1)',
          borderWidth: 1,
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
            labels: {
              boxWidth: 12,
              usePointStyle: true,
              pointStyle: 'rect'
            }
          },
          tooltip: {
            usePointStyle: true,
            backgroundColor: 'rgba(255, 255, 255, 0.9)',
            titleColor: '#111827',
            bodyColor: '#111827',
            borderColor: 'rgba(226, 232, 240, 1)',
            borderWidth: 1,
            padding: 12,
            boxPadding: 6,
            callbacks: {
              label: function(context) {
                return '$ ' + context.parsed.y.toFixed(2);
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '$' + value.toFixed(2);
              }
            },
            grid: {
              color: 'rgba(226, 232, 240, 0.5)'
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        }
      }
    })
  }

  // This is the method that's called when a tab is clicked
  switchTab(event) {
    event.preventDefault()
    const tabName = event.currentTarget.getAttribute('data-tab')
    console.log("Switching to tab:", tabName)
    this.showTab(tabName)
  }

  showTab(tabName) {
    console.log("Show tab method called with:", tabName)
    console.log("Tab targets:", this.tabTargets.length)
    console.log("Tab content targets:", this.tabContentTargets.length)
    
    // Update active tab styling
    this.tabTargets.forEach(tab => {
      const tabId = tab.getAttribute('data-tab')
      console.log("Checking tab:", tabId)
      
      if (tabId === tabName) {
        tab.classList.add('border-red-500', 'text-red-600')
        tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      } else {
        tab.classList.remove('border-red-500', 'text-red-600')
        tab.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })

    // Show/hide tab content
    this.tabContentTargets.forEach(content => {
      const contentId = content.getAttribute('data-tab')
      console.log("Checking content:", contentId)
      
      if (contentId === tabName) {
        content.classList.remove('hidden')
      } else {
        content.classList.add('hidden')
      }
    })
  }

  toggleSidebar() {
    console.log("Toggle sidebar called")
    this.sidebarTarget.classList.toggle('hidden')
    this.sidebarTarget.classList.toggle('lg:flex')
  }
}