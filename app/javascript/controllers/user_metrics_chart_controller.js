import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// User Metrics Chart Controller
//
// This controller handles the user metrics chart in the analytics dashboard.
// It manages the chart creation, updating, and period changes.
export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("User Metrics Chart controller connected")
    this.initializeChart()
  }

  // Initialize the user metrics chart
  initializeChart() {
    // If a previous chart exists, destroy it
    if (this.chart) {
      this.chart.destroy()
    }

    // Get the canvas element
    const canvas = document.createElement("canvas")
    canvas.id = "user-metrics-chart"
    this.containerTarget.innerHTML = ""
    this.containerTarget.appendChild(canvas)

    // Get dummy data for the chart
    const { labels, datasets } = this.getUserMetricsData('month')

    // Create the chart
    this.chart = new Chart(canvas, {
      type: "bar",
      data: {
        labels,
        datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              title: function(tooltipItems) {
                return `Day ${tooltipItems[0].label}`
              },
              label: function(context) {
                return `${context.dataset.label}: ${context.raw}k users`
              }
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            }
          },
          y: {
            beginAtZero: true,
            grid: {
              color: "rgba(0, 0, 0, 0.05)"
            },
            ticks: {
              callback: function(value) {
                return value + 'k'
              }
            }
          }
        }
      }
    })
  }

  // Handle period change from buttons
  setRange(event) {
    const period = event.currentTarget.dataset.period
    
    // Update the active button
    this.element.querySelectorAll('button').forEach(button => {
      if (button.dataset.period === period) {
        button.classList.remove('bg-white', 'text-gray-700')
        button.classList.add('bg-indigo-50', 'text-indigo-700', 'font-medium')
      } else {
        button.classList.remove('bg-indigo-50', 'text-indigo-700', 'font-medium')
        button.classList.add('bg-white', 'text-gray-700')
      }
    })
    
    // Update the chart with the new period data
    this.updateChartData(period)
  }

  // Update the chart with new data based on the period
  updateChartData(period) {
    // Get data for the selected period
    const { labels, datasets } = this.getUserMetricsData(period)
    
    // Update the chart data
    this.chart.data.labels = labels
    this.chart.data.datasets = datasets
    this.chart.update()
  }

  // Get dummy data for the user metrics chart based on period
  getUserMetricsData(period) {
    let labels = []
    let userValues = []
    let engagementValues = []
    
    // Create appropriate labels and data based on period
    switch (period) {
      case 'week':
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        userValues = [320, 385, 450, 410, 480, 520, 490]
        engagementValues = [7.5, 8.2, 9.1, 8.3, 9.5, 10.2, 9.7]
        break
      case 'month':
        labels = Array.from({ length: 30 }, (_, i) => (i + 1).toString())
        userValues = Array.from({ length: 30 }, () => Math.floor(Math.random() * 400) + 200)
        engagementValues = Array.from({ length: 30 }, () => (Math.random() * 5) + 5)
        break
      case 'quarter':
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        userValues = [280, 310, 340, 370, 430, 490, 520, 550, 510, 480, 440, 400]
        engagementValues = [6.2, 6.8, 7.3, 7.9, 8.4, 9.1, 9.8, 10.3, 9.7, 9.1, 8.5, 8.0]
        break
      default:
        labels = Array.from({ length: 30 }, (_, i) => (i + 1).toString())
        userValues = Array.from({ length: 30 }, () => Math.floor(Math.random() * 400) + 200)
        engagementValues = Array.from({ length: 30 }, () => (Math.random() * 5) + 5)
    }
    
    // Format data for Chart.js
    return {
      labels,
      datasets: [
        {
          label: 'User Count',
          data: userValues,
          backgroundColor: 'rgba(79, 70, 229, 0.8)',
          borderColor: 'rgba(79, 70, 229, 1)',
          borderWidth: 1
        },
        {
          label: 'Engagement %',
          data: engagementValues,
          backgroundColor: 'rgba(16, 185, 129, 0.6)',
          borderColor: 'rgba(16, 185, 129, 1)',
          borderWidth: 1
        }
      ]
    }
  }
}