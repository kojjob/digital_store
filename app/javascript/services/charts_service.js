/**
 * ChartsService - Handles chart rendering throughout the dashboard
 * 
 * This service is responsible for fetching chart data from the API
 * and rendering it using Chart.js. It follows a modular approach
 * and domain-driven design by separating chart concerns from other UI logic.
 */

export default class ChartsService {
  constructor() {
    this.charts = {};
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    this.defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
        },
        tooltip: {
          mode: 'index',
          intersect: false,
        },
      },
    };
  }

  /**
   * Initialize the charts on the dashboard
   */
  init() {
    // Revenue chart
    this.initRevenueChart();
    
    // Orders chart
    this.initOrdersChart();
    
    // Product performance chart
    this.initProductPerformanceChart();
    
    // Customer acquisition chart
    this.initCustomerAcquisitionChart();
    
    // Setup event listeners for period selection
    this.setupEventListeners();
  }

  /**
   * Initialize the revenue chart
   */
  async initRevenueChart() {
    const chartContainer = document.getElementById('revenue-chart');
    if (!chartContainer) return;
    
    try {
      const data = await this.fetchChartData('/api/charts/revenue');
      this.renderLineChart('revenue-chart', data, {
        ...this.defaultOptions,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '$' + value;
              }
            }
          }
        }
      });
    } catch (error) {
      console.error('Error initializing revenue chart:', error);
      this.showChartError(chartContainer);
    }
  }

  /**
   * Initialize the orders chart
   */
  async initOrdersChart() {
    const chartContainer = document.getElementById('orders-chart');
    if (!chartContainer) return;
    
    try {
      const data = await this.fetchChartData('/api/charts/orders');
      this.renderBarChart('orders-chart', data, {
        ...this.defaultOptions,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      });
    } catch (error) {
      console.error('Error initializing orders chart:', error);
      this.showChartError(chartContainer);
    }
  }

  /**
   * Initialize the product performance chart
   */
  async initProductPerformanceChart() {
    const chartContainer = document.getElementById('product-performance-chart');
    if (!chartContainer) return;
    
    try {
      const data = await this.fetchChartData('/api/charts/product_performance');
      this.renderBarChart('product-performance-chart', data, {
        ...this.defaultOptions,
        indexAxis: 'y',
        scales: {
          x: {
            beginAtZero: true
          }
        }
      });
    } catch (error) {
      console.error('Error initializing product performance chart:', error);
      this.showChartError(chartContainer);
    }
  }

  /**
   * Initialize the customer acquisition chart
   */
  async initCustomerAcquisitionChart() {
    const chartContainer = document.getElementById('customer-acquisition-chart');
    if (!chartContainer) return;
    
    try {
      const data = await this.fetchChartData('/api/charts/customer_acquisition');
      this.renderLineChart('customer-acquisition-chart', data, {
        ...this.defaultOptions,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      });
    } catch (error) {
      console.error('Error initializing customer acquisition chart:', error);
      this.showChartError(chartContainer);
    }
  }

  /**
   * Fetch chart data from the API
   * @param {string} endpoint - API endpoint to fetch data from
   * @param {Object} params - Query parameters to include
   * @returns {Promise<Object>} Chart data
   */
  async fetchChartData(endpoint, params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const url = `${endpoint}${queryString ? '?' + queryString : ''}`;
    
    const response = await fetch(url, {
      headers: {
        'X-CSRF-Token': this.csrfToken,
        'Accept': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
    return await response.json();
  }

  /**
   * Render a line chart
   * @param {string} elementId - ID of the canvas element
   * @param {Object} data - Chart data
   * @param {Object} options - Chart options
   */
  renderLineChart(elementId, data, options = {}) {
    const ctx = document.getElementById(elementId);
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (this.charts[elementId]) {
      this.charts[elementId].destroy();
    }
    
    this.charts[elementId] = new Chart(ctx, {
      type: 'line',
      data: data,
      options: options
    });
  }

  /**
   * Render a bar chart
   * @param {string} elementId - ID of the canvas element
   * @param {Object} data - Chart data
   * @param {Object} options - Chart options
   */
  renderBarChart(elementId, data, options = {}) {
    const ctx = document.getElementById(elementId);
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (this.charts[elementId]) {
      this.charts[elementId].destroy();
    }
    
    this.charts[elementId] = new Chart(ctx, {
      type: 'bar',
      data: data,
      options: options
    });
  }

  /**
   * Set up event listeners for chart period selection
   */
  setupEventListeners() {
    document.querySelectorAll('[data-chart-period]').forEach(button => {
      button.addEventListener('click', async (e) => {
        e.preventDefault();
        
        const chartId = button.dataset.chartId;
        const period = button.dataset.chartPeriod;
        
        // Update active state for period buttons
        document.querySelectorAll(`[data-chart-id="${chartId}"]`).forEach(btn => {
          btn.classList.remove('bg-indigo-600', 'text-white');
          btn.classList.add('text-gray-500', 'bg-white');
        });
        
        button.classList.remove('text-gray-500', 'bg-white');
        button.classList.add('bg-indigo-600', 'text-white');
        
        // Update chart data
        await this.updateChartData(chartId, period);
      });
    });
  }

  /**
   * Update chart data based on the selected period
   * @param {string} chartId - ID of the chart to update
   * @param {string} period - Selected period (week, month, year)
   */
  async updateChartData(chartId, period) {
    let endpoint;
    
    if (chartId === 'revenue-chart') {
      endpoint = '/api/charts/revenue';
    } else if (chartId === 'orders-chart') {
      endpoint = '/api/charts/orders';
    } else {
      return;
    }
    
    try {
      const data = await this.fetchChartData(endpoint, { period });
      
      if (chartId === 'revenue-chart') {
        this.renderLineChart(chartId, data, this.charts[chartId].options);
      } else if (chartId === 'orders-chart') {
        this.renderBarChart(chartId, data, this.charts[chartId].options);
      }
    } catch (error) {
      console.error(`Error updating chart ${chartId}:`, error);
      
      const chartContainer = document.getElementById(chartId);
      if (chartContainer) {
        this.showChartError(chartContainer);
      }
    }
  }

  /**
   * Show an error message when chart loading fails
   * @param {HTMLElement} container - The chart container element
   */
  showChartError(container) {
    container.innerHTML = `
      <div class="flex flex-col items-center justify-center h-64 bg-gray-50 rounded-lg border border-gray-200">
        <svg class="h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">Failed to load chart</h3>
        <p class="mt-1 text-sm text-gray-500">There was an error loading this chart. Please try again later.</p>
        <button type="button" class="mt-3 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" onclick="window.location.reload()">
          Refresh
        </button>
      </div>
    `;
  }
}

// Initialize the charts when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Only initialize on pages with charts
  if (document.querySelector('[data-chart-id]')) {
    const chartsService = new ChartsService();
    chartsService.init();
  }
});
