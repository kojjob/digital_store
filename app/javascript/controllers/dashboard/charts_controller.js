import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["platformActivity", "revenue"]
  static values = {
    chartMonths: Array,
    userData: Array,
    orderData: Array,
    revenueData: Array
  }

  connect() {
    this.initializePlatformActivityChart()
    this.initializeRevenueChart()
  }

  initializePlatformActivityChart() {
    if (!this.hasPlatformActivityTarget) return

    const activityCtx = this.platformActivityTarget.getContext('2d')
    
    new Chart(activityCtx, {
      type: 'line',
      data: {
        labels: this.chartMonthsValue,
        datasets: [{
          label: 'New Users',
          data: this.userDataValue,
          backgroundColor: 'rgba(239, 68, 68, 0.2)',
          borderColor: 'rgba(239, 68, 68, 1)',
          borderWidth: 2,
          tension: 0.4,
          pointRadius: 4,
          pointBackgroundColor: 'rgba(239, 68, 68, 1)'
        }, {
          label: 'Orders',
          data: this.orderDataValue,
          backgroundColor: 'rgba(59, 130, 246, 0.2)',
          borderColor: 'rgba(59, 130, 246, 1)',
          borderWidth: 2,
          tension: 0.4,
          pointRadius: 4,
          pointBackgroundColor: 'rgba(59, 130, 246, 1)'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          tooltip: {
            mode: 'index',
            intersect: false,
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        },
        interaction: {
          mode: 'index',
          intersect: false,
        }
      }
    })
  }

  initializeRevenueChart() {
    if (!this.hasRevenueTarget) return

    const revenueCtx = this.revenueTarget.getContext('2d')
    
    new Chart(revenueCtx, {
      type: 'bar',
      data: {
        labels: this.chartMonthsValue,
        datasets: [{
          label: 'Revenue',
          data: this.revenueDataValue,
          backgroundColor: 'rgba(16, 185, 129, 0.8)',
          borderColor: 'rgba(16, 185, 129, 1)',
          borderWidth: 1,
          borderRadius: 6,
          maxBarThickness: 20
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return '$' + context.parsed.y.toFixed(2)
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '$' + value.toFixed(2)
              }
            }
          }
        }
      }
    })
  }

  toggleChartPeriod(event) {
    // This method can be implemented to handle period switching (monthly/quarterly)
    // Example implementation would fetch new data via AJAX and update the charts
    const period = event.currentTarget.dataset.period
    const chartType = event.currentTarget.dataset.chartType
    
    // Here you would typically fetch new data based on period and chart type
    // Then update the appropriate chart
    
    // For now, just update the button states
    event.currentTarget.closest('.flex').querySelectorAll('button').forEach(btn => {
      btn.classList.remove('bg-red-50', 'text-red-700', 'border-red-300')
      btn.classList.add('bg-white', 'text-gray-700', 'border-gray-300')
    })
    
    event.currentTarget.classList.remove('bg-white', 'text-gray-700', 'border-gray-300')
    event.currentTarget.classList.add('bg-red-50', 'text-red-700', 'border-red-300')
  }
}
