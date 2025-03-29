import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Income Chart Controller
//
// This controller handles the monthly income chart in the analytics dashboard.
// It manages the chart creation, updating, and period changes.
export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("Income Chart controller connected")
    this.initializeChart()
  }

  // Initialize the income chart
  initializeChart() {
    // If a previous chart exists, destroy it
    if (this.chart) {
      this.chart.destroy()
    }

    // Get the canvas element
    const canvas = document.createElement("canvas")
    canvas.id = "income-chart"
    this.containerTarget.innerHTML = ""
    this.containerTarget.appendChild(canvas)

    // Get dummy data for the chart
    const { labels, datasets } = this.getIncomeData('current')

    // Create the chart
    this.chart = new Chart(canvas, {
      type: "line",
      data: {
        labels,
        datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'top',
            labels: {
              boxWidth: 12,
              padding: 15
            }
          },
          tooltip: {
            intersect: false,
            mode: 'index',
            callbacks: {
              label: function(context) {
                let label = context.dataset.label || '';
                if (label) {
                  label += ': ';
                }
                if (context.parsed.y !== null) {
                  label += new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(context.parsed.y);
                }
                return label;
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
                return '$' + value;
              }
            }
          }
        },
        elements: {
          line: {
            tension: 0.4
          },
          point: {
            radius: 3,
            hoverRadius: 5
          }
        }
      }
    })
  }

  // Handle month change from dropdown
  changeMonth(event) {
    const period = event.target.value
    this.updateChartData(period)
  }

  // Update the chart with new data based on the selected month
  updateChartData(period) {
    // Get data for the selected period
    const { labels, datasets } = this.getIncomeData(period)
    
    // Update the chart data
    this.chart.data.labels = labels
    this.chart.data.datasets = datasets
    this.chart.update()
  }

  // Get dummy data for the income chart based on period
  getIncomeData(period) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    let labels = []
    let datasets = []
    
    // Create appropriate labels and data based on period
    switch (period) {
      case 'current':
        labels = weekdays
        datasets = [
          {
            label: 'Current Month',
            data: [45, 58, 65, 70, 85, 67, 78],
            borderColor: 'rgba(79, 70, 229, 1)',
            backgroundColor: 'rgba(79, 70, 229, 0.1)',
            fill: true
          }
        ]
        break
      case 'previous':
        labels = weekdays
        datasets = [
          {
            label: 'Previous Month',
            data: [38, 42, 55, 62, 70, 52, 63],
            borderColor: 'rgba(16, 185, 129, 1)',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            fill: true
          }
        ]
        break
      case 'comparison':
        labels = weekdays
        datasets = [
          {
            label: 'Current Month',
            data: [45, 58, 65, 70, 85, 67, 78],
            borderColor: 'rgba(79, 70, 229, 1)',
            backgroundColor: 'transparent',
            borderWidth: 2
          },
          {
            label: 'Previous Month',
            data: [38, 42, 55, 62, 70, 52, 63],
            borderColor: 'rgba(16, 185, 129, 1)',
            backgroundColor: 'transparent',
            borderWidth: 2,
            borderDash: [5, 5]
          }
        ]
        break
      default:
        labels = weekdays
        datasets = [
          {
            label: 'Income',
            data: [45, 58, 65, 70, 85, 67, 78],
            borderColor: 'rgba(79, 70, 229, 1)',
            backgroundColor: 'rgba(79, 70, 229, 0.1)',
            fill: true
          }
        ]
    }
    
    // Format data for Chart.js
    return { labels, datasets }
  }
}