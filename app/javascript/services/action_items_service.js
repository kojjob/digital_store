/**
 * ActionItemsService - Manages user action items
 * 
 * This service handles CRUD operations for action items in the dashboard.
 * It follows domain-driven design principles by encapsulating the business
 * rules and behaviors related to action items in a single module.
 */

export default class ActionItemsService {
  constructor() {
    this.actionItems = [];
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  }

  /**
   * Initialize the service
   * @param {Array} existingItems - Existing action items from the server
   */
  init(existingItems = []) {
    this.actionItems = existingItems;
    this.bindEvents();
  }

  /**
   * Bind events to action item elements
   */
  bindEvents() {
    // Handle checkbox toggles
    document.querySelectorAll('input[id^="action_"]').forEach(checkbox => {
      checkbox.addEventListener('change', this.handleToggleComplete.bind(this));
    });

    // Handle add new action button
    const addButton = document.querySelector('button[aria-label="Add new action"]');
    if (addButton) {
      addButton.addEventListener('click', this.handleAddNew.bind(this));
    }
  }

  /**
   * Handle toggling an action item's completion status
   * @param {Event} event - The change event
   */
  async handleToggleComplete(event) {
    const checkbox = event.target;
    const actionId = checkbox.id.replace('action_', '');
    const isCompleted = checkbox.checked;

    try {
      const response = await fetch(`/api/action_items/${actionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify({ completed: isCompleted })
      });

      if (!response.ok) {
        throw new Error('Failed to update action item');
      }

      // Update the UI to reflect the change
      const label = document.querySelector(`label[for="action_${actionId}"]`);
      if (label) {
        if (isCompleted) {
          label.classList.add('line-through', 'text-gray-400');
        } else {
          label.classList.remove('line-through', 'text-gray-400');
        }
      }
    } catch (error) {
      console.error('Error updating action item:', error);
      // Revert the checkbox state
      checkbox.checked = !isCompleted;
      
      // Show error message
      this.showNotification('Error updating action item', 'error');
    }
  }

  /**
   * Handle adding a new action item
   */
  handleAddNew() {
    // Create a modal or form for adding a new action item
    // This would typically be implemented with a Stimulus controller
    console.log('Add new action item');
    
    // Simple example: show a prompt for now
    const title = prompt('Enter a title for the new action item:');
    if (!title) return;
    
    const description = prompt('Enter a description:');
    const priority = prompt('Enter priority (high, medium, low):');
    
    this.createActionItem({
      title,
      description: description || '',
      priority: ['high', 'medium', 'low'].includes(priority?.toLowerCase()) 
        ? priority.toLowerCase() 
        : 'medium'
    });
  }

  /**
   * Create a new action item
   * @param {Object} actionItem - The action item details
   */
  async createActionItem(actionItem) {
    try {
      const response = await fetch('/api/action_items', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify(actionItem)
      });

      if (!response.ok) {
        throw new Error('Failed to create action item');
      }

      const newItem = await response.json();
      
      // Add the new item to the UI
      this.addActionItemToUI(newItem);
      
      // Show success message
      this.showNotification('Action item created successfully', 'success');
    } catch (error) {
      console.error('Error creating action item:', error);
      this.showNotification('Error creating action item', 'error');
    }
  }

  /**
   * Add a new action item to the UI
   * @param {Object} item - The action item to add
   */
  addActionItemToUI(item) {
    const container = document.querySelector('.space-y-5');
    if (!container) return;

    const priorityColor = item.priority === 'high' 
      ? 'amber' 
      : (item.priority === 'medium' ? 'blue' : 'green');

    const itemHTML = `
      <div class="relative flex items-start">
        <div class="flex items-center h-5">
          <input id="action_${item.id}" name="action_${item.id}" type="checkbox" class="focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded">
        </div>
        <div class="ml-3 flex justify-between flex-1">
          <div>
            <label for="action_${item.id}" class="text-sm font-medium text-gray-700">${item.title}</label>
            <p class="text-sm text-gray-500">${item.description}</p>
          </div>
          <span class="text-xs font-medium text-${priorityColor}-500">
            ${item.priority.charAt(0).toUpperCase() + item.priority.slice(1)} Priority
          </span>
        </div>
      </div>
    `;

    // Add to DOM
    container.insertAdjacentHTML('afterbegin', itemHTML);
    
    // Bind event to the new checkbox
    const newCheckbox = document.getElementById(`action_${item.id}`);
    if (newCheckbox) {
      newCheckbox.addEventListener('change', this.handleToggleComplete.bind(this));
    }
  }

  /**
   * Show a notification message
   * @param {string} message - The message to display
   * @param {string} type - The type of notification (success, error, info)
   */
  showNotification(message, type = 'info') {
    // This would typically use a notification library or custom implementation
    const colors = {
      success: 'bg-green-100 text-green-800 border-green-400',
      error: 'bg-red-100 text-red-800 border-red-400',
      info: 'bg-blue-100 text-blue-800 border-blue-400'
    };
    
    const notificationArea = document.getElementById('notification-area') || document.body;
    
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 px-4 py-3 rounded-md border ${colors[type]} shadow-md transition-opacity duration-500`;
    notification.innerHTML = message;
    
    notificationArea.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
      notification.style.opacity = '0';
      setTimeout(() => notification.remove(), 500);
    }, 3000);
  }
}

// Initialize the service when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // We'll only initialize if we're on the dashboard page
  if (document.querySelector('.action-items-container')) {
    const actionItemsService = new ActionItemsService();
    
    // Example of initializing with existing items
    // In a real app, these would come from the server
    actionItemsService.init(window.actionItems || []);
  }
});
