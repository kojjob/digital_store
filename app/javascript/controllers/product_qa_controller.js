import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "questionInput", "questionsContainer", "loadMoreButton", "emptyState"]
  static values = {
    productId: String,
    apiUrl: String,
    page: { type: Number, default: 1 },
    perPage: { type: Number, default: 5 },
    totalPages: Number
  }
  
  connect() {
    // Set default API URL if not provided
    if (!this.hasApiUrlValue) {
      this.apiUrlValue = '/api/product_questions'
    }
    
    // Load initial questions
    this.loadQuestions()
  }
  
  submitQuestion(event) {
    event.preventDefault()
    
    if (!this.hasQuestionInputTarget || !this.questionInputTarget.value.trim()) {
      // Validate question is not empty
      this.showFormError("Please enter your question")
      return
    }
    
    // Show loading state
    this.toggleFormLoading(true)
    
    // Prepare form data
    const formData = new FormData(this.formTarget)
    
    // Send request to server
    fetch(this.apiUrlValue, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken()
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Clear form and show success message
        this.questionInputTarget.value = ''
        this.showFormSuccess("Your question has been submitted successfully. It will be answered soon.")
        
        // Reload questions to include the new one
        this.loadQuestions(true)
      } else {
        // Show error
        this.showFormError(data.error || "There was an error submitting your question.")
      }
    })
    .catch(error => {
      console.error("Error submitting question:", error)
      this.showFormError("There was an error submitting your question. Please try again.")
    })
    .finally(() => {
      this.toggleFormLoading(false)
    })
  }
  
  loadQuestions(reset = false) {
    if (reset) {
      this.pageValue = 1
    }
    
    const url = new URL(this.apiUrlValue, window.location.origin)
    url.searchParams.append('product_id', this.productIdValue)
    url.searchParams.append('page', this.pageValue)
    url.searchParams.append('per_page', this.perPageValue)
    
    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.questions && data.questions.length > 0) {
        // Update total pages
        this.totalPagesValue = data.total_pages || 1
        
        // Render questions
        if (reset) {
          this.questionsContainerTarget.innerHTML = ''
        }
        
        data.questions.forEach(question => {
          this.questionsContainerTarget.appendChild(this.createQuestionElement(question))
        })
        
        // Show/hide load more button
        if (this.hasLoadMoreButtonTarget) {
          this.loadMoreButtonTarget.classList.toggle('hidden', this.pageValue >= this.totalPagesValue)
        }
        
        // Hide empty state if visible
        if (this.hasEmptyStateTarget) {
          this.emptyStateTarget.classList.add('hidden')
        }
      } else if (this.pageValue === 1) {
        // Show empty state if no questions and on first page
        if (this.hasEmptyStateTarget) {
          this.emptyStateTarget.classList.remove('hidden')
        }
        
        // Hide load more button
        if (this.hasLoadMoreButtonTarget) {
          this.loadMoreButtonTarget.classList.add('hidden')
        }
      }
    })
    .catch(error => {
      console.error("Error loading questions:", error)
    })
  }
  
  loadMore(event) {
    event.preventDefault()
    this.pageValue++
    this.loadQuestions()
  }
  
  createQuestionElement(question) {
    const div = document.createElement('div')
    div.className = 'pt-6 first:pt-0 border-t border-gray-200 first:border-t-0'
    
    let answerHtml = ''
    if (question.answer) {
      answerHtml = `
        <div class="mt-4 bg-gray-50 p-3 rounded-lg">
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <div class="ml-3 flex-1">
              <p class="text-sm text-gray-700">${question.answer}</p>
              <div class="mt-1 text-xs text-gray-500">
                <span>Answered by ${question.answered_by} • ${this.formatDate(question.answered_at)}</span>
              </div>
            </div>
          </div>
        </div>
      `
    } else {
      answerHtml = `
        <div class="mt-3">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
            Awaiting answer
          </span>
        </div>
      `
    }
    
    div.innerHTML = `
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-900">${question.question}</p>
          <div class="mt-1 text-xs text-gray-500">
            <span>Asked by ${question.asked_by} • ${this.formatDate(question.asked_at)}</span>
          </div>
          
          ${answerHtml}
        </div>
      </div>
    `
    
    return div
  }
  
  formatDate(dateString) {
    if (!dateString) return ''
    
    const date = new Date(dateString)
    const options = { year: 'numeric', month: 'long', day: 'numeric' }
    return date.toLocaleDateString(undefined, options)
  }
  
  showFormSuccess(message) {
    const successDiv = this.createAlertElement(message, 'success')
    this.formTarget.insertAdjacentElement('afterend', successDiv)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      successDiv.remove()
    }, 5000)
  }
  
  showFormError(message) {
    const errorDiv = this.createAlertElement(message, 'error')
    this.formTarget.insertAdjacentElement('afterend', errorDiv)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      errorDiv.remove()
    }, 5000)
  }
  
  createAlertElement(message, type) {
    const div = document.createElement('div')
    
    let bgColor, textColor, iconHtml
    if (type === 'success') {
      bgColor = 'bg-green-50'
      textColor = 'text-green-800'
      iconHtml = `
        <svg class="h-5 w-5 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      `
    } else {
      bgColor = 'bg-red-50'
      textColor = 'text-red-800'
      iconHtml = `
        <svg class="h-5 w-5 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      `
    }
    
    div.className = `mt-3 p-4 rounded-md ${bgColor} animate-fade-in`
    div.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          ${iconHtml}
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium ${textColor}">${message}</p>
        </div>
      </div>
    `
    
    return div
  }
  
  toggleFormLoading(isLoading) {
    const submitButton = this.formTarget.querySelector('button[type="submit"]')
    if (!submitButton) return
    
    submitButton.disabled = isLoading
    
    if (isLoading) {
      submitButton.innerHTML = `
        <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Submitting...
      `
    } else {
      submitButton.textContent = 'Submit Question'
    }
  }
  
  getCSRFToken() {
    const metaTag = document.querySelector('meta[name="csrf-token"]')
    return metaTag ? metaTag.getAttribute('content') : ''
  }
}
