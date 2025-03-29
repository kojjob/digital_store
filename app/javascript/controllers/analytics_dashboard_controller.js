import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Analytics Dashboard Controller
//
// This controller handles the interactive features of the enhanced analytics dashboard.
// It manages period changes, visitor filters, and product sorting.
export default class extends Controller {
  static targets = []

  connect() {
    console.log("Analytics Dashboard controller connected")
    this.initializeCharts()
  }

  // Initialize charts when data is available
  initializeCharts() {
    // Charts will be initialized by their respective controllers
    // This is just a placeholder for global dashboard initialization
  }

  // Handle time period changes for the dashboard data
  changePeriod(event) {
    const period = event.target.value
    console.log(`Period changed to: ${period} days`)
    
    // In a real implementation, we would fetch new data based on the period
    // For now, we'll just log it
    // this.fetchDashboardData(period)
  }

  // Handle filtering of visitor data
  filterVisitors(event) {
    const filterType = event.target.value
    console.log(`Filtering visitors by: ${filterType}`)
    
    // In a real implementation, we would update the visitor chart based on the filter
    // For now, we'll just log it
  }

  // Handle sorting of products table
  sortProducts(event) {
    const sortType = event.target.value
    console.log(`Sorting products by: ${sortType}`)
    
    // In a real implementation, we would sort the products table
    // For now, we'll just log it
  }

  // Fetch dashboard data from the server (example implementation)
  fetchDashboardData(period) {
    fetch(`/dashboard/data?period=${period}`, {
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.json())
    .then(data => {
      console.log("Received new dashboard data:", data)
      // In a real implementation, we would update the UI with the new data
      // this.updateDashboardData(data)
    })
    .catch(error => {
      console.error("Error fetching dashboard data:", error)
    })
  }
}