import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "calendarContainer", 
    "monthTitle",
    "meetingList",
    "dateSelector",
    "calendarDays",
    "eventModal",
    "eventTitle",
    "eventDate",
    "eventTime",
    "eventDuration",
    "eventType",
    "eventNotes",
    "toast",
    "toastTitle",
    "toastMessage",
    "eventDetailsModal",
    "eventDetailsTitle",
    "eventDetailsDate",
    "eventDetailsTime",
    "eventDetailsType",
    "eventDetailsNotes",
    "eventDetailsAvatar"
  ]
  
  static values = {
    currentDate: String,
    events: Array,
    selectedDate: String
  }
  
  connect() {
    this.currentMonth = new Date()
    if (!this.hasCurrentDateValue) {
      this.currentDateValue = new Date().toISOString()
    }
    
    // Set default selected date to today
    const today = new Date()
    this.selectedDateValue = today.toISOString().split('T')[0]
    
    // Initialize default values for the new event form
    if (this.hasEventDateTarget) {
      this.eventDateTarget.value = this.selectedDateValue
    }
    if (this.hasEventTimeTarget) {
      const hours = today.getHours()
      const minutes = today.getMinutes() >= 30 ? '30' : '00'
      this.eventTimeTarget.value = `${hours}:${minutes}`
    }
    
    this.initializeCalendar()
    this.loadEvents()
    
    // Fix all select elements on page load
    this.fixAllSelectElements()
  }
  
  // Fix visibility of all select elements
  fixAllSelectElements() {
    const allSelects = document.querySelectorAll('select')
    allSelects.forEach(select => {
      // Force native dropdown appearance
      select.style.webkitAppearance = 'menulist'
      select.style.mozAppearance = 'menulist'
      select.style.appearance = 'menulist'
      select.style.backgroundImage = 'none'
      select.style.backgroundColor = '#ffffff'
      select.style.color = '#000000'
      select.style.border = '3px solid #4f46e5'
      select.style.padding = '0.75rem'
      select.style.fontSize = '16px'
      select.style.position = 'relative'
      select.style.zIndex = '50'
    })
  }
  
  initializeCalendar() {
    this.renderCalendar()
  }
  
  // Navigate to previous month
  prevMonth() {
    this.currentMonth.setMonth(this.currentMonth.getMonth() - 1)
    this.renderCalendar()
  }
  
  // Navigate to next month
  nextMonth() {
    this.currentMonth.setMonth(this.currentMonth.getMonth() + 1)
    this.renderCalendar()
  }
  
  // Render the calendar for the current month
  renderCalendar() {
    const year = this.currentMonth.getFullYear()
    const month = this.currentMonth.getMonth()
    
    // Update month title
    const monthNames = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
    this.monthTitleTarget.textContent = `${monthNames[month]} ${year}`
    
    // Calculate first and last day of month
    const firstDay = new Date(year, month, 1)
    const lastDay = new Date(year, month + 1, 0)
    
    // Calculate the number of days in the previous month we need to display
    const firstDayOfWeek = firstDay.getDay() // 0 = Sunday, 1 = Monday, etc.
    
    // Clear the calendar
    this.clearCalendar()
    
    // Previous month's days
    const prevMonthLastDay = new Date(year, month, 0).getDate()
    for (let i = firstDayOfWeek - 1; i >= 0; i--) {
      const dayNum = prevMonthLastDay - i
      this.addDayToCalendar(dayNum, true, false)
    }
    
    // Current month's days
    const today = new Date()
    const isCurrentMonth = today.getMonth() === month && today.getFullYear() === year
    
    for (let i = 1; i <= lastDay.getDate(); i++) {
      const isToday = isCurrentMonth && today.getDate() === i
      const hasEvent = this.dayHasEvent(year, month, i)
      this.addDayToCalendar(i, false, isToday, hasEvent)
    }
    
    // Next month's days
    const daysFromNextMonth = 42 - (firstDayOfWeek + lastDay.getDate())
    for (let i = 1; i <= daysFromNextMonth; i++) {
      this.addDayToCalendar(i, true, false)
    }
  }
  
  // Clear the calendar days
  clearCalendar() {
    if (this.hasCalendarDaysTarget) {
      this.calendarDaysTarget.innerHTML = ''
    }
  }
  
  // Add a day to the calendar
  addDayToCalendar(dayNum, isOtherMonth, isToday, hasEvent = false) {
    if (!this.hasCalendarDaysTarget) return
    
    const dayElement = document.createElement('div')
    dayElement.className = 'py-1 relative'
    
    // Create date string for this day
    const dateData = new Date(this.currentMonth.getFullYear(), this.currentMonth.getMonth(), dayNum)
    const dateStr = dateData.toISOString().split('T')[0]
    
    // Check if this is the selected date
    const isSelected = dateStr === this.selectedDateValue
    
    let dayClass = isOtherMonth 
      ? 'text-gray-400 hover:bg-gray-50'
      : isToday
        ? 'bg-indigo-600 text-white shadow-md'
        : isSelected
          ? 'bg-indigo-100 text-indigo-800 font-medium'
          : hasEvent
            ? 'text-indigo-600 font-medium hover:bg-indigo-50'
            : 'hover:bg-gray-100 text-gray-700'
    
    dayElement.innerHTML = `
      <div class="${dayClass} rounded-full w-8 h-8 flex items-center justify-center mx-auto transition-colors cursor-pointer"
           data-action="click->schedule#selectDay">
        ${dayNum}
      </div>
      ${hasEvent ? '<div class="absolute bottom-0 left-1/2 transform -translate-x-1/2 w-1.5 h-1.5 rounded-full bg-indigo-600"></div>' : ''}
    `
    
    // Store date data for this day
    if (!isOtherMonth) {
      dayElement.firstElementChild.dataset.date = dateStr
    }
    
    this.calendarDaysTarget.appendChild(dayElement)
  }
  
  // Check if a day has any events
  dayHasEvent(year, month, day) {
    if (!this.hasEventsValue) return false
    
    const dateStr = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    return this.eventsValue.some(event => event.date === dateStr)
  }
  
  // Handle day selection
  selectDay(event) {
    if (!event.currentTarget.dataset.date) return
    
    // Set the selected date
    this.selectedDateValue = event.currentTarget.dataset.date
    
    // Refresh the calendar to update the selected day styling
    this.renderCalendar()
    
    // Update meetings list for this day
    this.updateMeetingsList(this.selectedDateValue)
    
    // Update the event date in the form if it's open
    if (this.hasEventDateTarget) {
      this.eventDateTarget.value = this.selectedDateValue
    }
  }
  
  // Update the displayed meetings for selected date
  updateMeetingsList(dateStr) {
    if (!this.hasMeetingListTarget) return
    
    // Filter events for this date
    const dateEvents = this.hasEventsValue 
      ? this.eventsValue.filter(event => event.date === dateStr)
      : []
    
    if (dateEvents.length === 0) {
      this.meetingListTarget.innerHTML = `
        <div class="text-center py-8">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <p class="mt-2 text-gray-500">No events scheduled for this day</p>
        </div>
      `
    } else {
      this.meetingListTarget.innerHTML = dateEvents.map(event => this.renderEventItem(event)).join('')
    }
  }
  
  // Render an individual event item
  renderEventItem(event) {
    return `
      <div class="rounded-lg border border-gray-200 p-4 hover:shadow-lg transition-shadow bg-white group mb-4">
        <div class="flex items-start">
          <div class="flex-shrink-0 mr-4">
            <div class="w-10 h-10 rounded-full ${event.color || 'bg-indigo-100'} flex items-center justify-center">
              <span class="text-sm font-medium">${event.initials || 'EV'}</span>
            </div>
          </div>
          <div class="flex-grow">
            <h4 class="font-medium">${event.title}</h4>
            <div class="flex items-center mt-1">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-400 mr-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
              </svg>
              <p class="text-sm text-gray-600">${event.time}</p>
            </div>
          </div>
          <div class="flex-shrink-0">
            <button 
              class="text-gray-400 hover:text-indigo-600 p-1 rounded-full hover:bg-gray-50 transition-colors group-hover:bg-gray-50"
              data-event-id="${event.id}"
              data-action="click->schedule#openEventDetailsModal">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    `
  }
  
  // Load events from the server or initialize with sample data
  loadEvents() {
    // This would normally fetch from the server
    // For now, populate with sample data
    const today = new Date()
    const year = today.getFullYear()
    const month = today.getMonth() + 1
    const day = today.getDate()
    
    const formattedDate = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)
    const formattedTomorrow = `${tomorrow.getFullYear()}-${(tomorrow.getMonth() + 1).toString().padStart(2, '0')}-${tomorrow.getDate().toString().padStart(2, '0')}`
    
    // Create sample events
    this.eventsValue = [
      {
        id: 1,
        title: "Product Demo Call",
        date: formattedDate,
        time: "08:00 - 09:00",
        initials: "MC",
        color: "bg-amber-100 text-amber-600",
        type: "demo"
      },
      {
        id: 2,
        title: "Customer Support Call",
        date: formattedDate,
        time: "12:00 - 13:00",
        initials: "DP",
        color: "bg-indigo-100 text-indigo-600",
        type: "support"
      },
      {
        id: 3,
        title: "Product Customization Call",
        date: formattedDate,
        time: "15:00 - 16:00",
        initials: "CL",
        color: "bg-red-100 text-red-600",
        type: "customization"
      },
      {
        id: 4,
        title: "Feature Review Meeting",
        date: formattedTomorrow,
        time: "10:00 - 11:30",
        initials: "RT",
        color: "bg-green-100 text-green-600",
        type: "other",
        notes: "Prepare demo of new calendar feature for client review."
      },
      {
        id: 5,
        title: "Team Sync Up",
        date: formattedTomorrow,
        time: "14:00 - 15:00",
        initials: "TS",
        color: "bg-purple-100 text-purple-600",
        type: "other"
      }
    ]
    
    // Initialize with today's events
    this.updateMeetingsList(formattedDate)
  }
  
  // Change time period when selecting from dropdown
  changePeriod(event) {
    const period = event.target.value
    const today = new Date()
    
    // Reset to current month
    this.currentMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    
    if (period === 'last-30-days') {
      // No action needed, we'll show current month
    } else if (period === 'next-30-days') {
      this.currentMonth.setMonth(this.currentMonth.getMonth() + 1)
    } else if (period === 'current-year') {
      // No action needed, we'll show current month
    }
    
    this.renderCalendar()
  }
  
  // Open the new event modal
  openNewEventModal() {
    // Set the event date to the currently selected date
    if (this.hasEventDateTarget && this.selectedDateValue) {
      this.eventDateTarget.value = this.selectedDateValue
    }
    
    // Show the modal
    if (this.hasEventModalTarget) {
      this.eventModalTarget.classList.remove('hidden')
      // Focus on the title input and fix form elements
      if (this.hasEventTitleTarget) {
        setTimeout(() => {
          this.eventTitleTarget.focus()
          this.fixModalSelects()
        }, 100)
      }
    }
  }
  
  // Fix select elements in the modal
  fixModalSelects() {
    const selects = document.querySelectorAll('#eventModal select')
    selects.forEach(select => {
      // Force native dropdown appearance
      select.style.webkitAppearance = 'menulist'
      select.style.mozAppearance = 'menulist'
      select.style.appearance = 'menulist'
      select.style.backgroundImage = 'none'
      select.style.backgroundColor = '#ffffff'
      select.style.color = '#000000'
      select.style.border = '3px solid #4f46e5'
      select.style.padding = '0.75rem'
      select.style.fontSize = '16px'
      select.style.position = 'relative'
      select.style.zIndex = '50'
      
      // Make options visible
      const options = select.querySelectorAll('option')
      options.forEach(option => {
        option.style.backgroundColor = '#ffffff'
        option.style.color = '#000000'
        option.style.fontSize = '16px'
        option.style.padding = '8px'
      })
    })
  }
  
  // Close the new event modal
  closeNewEventModal() {
    if (this.hasEventModalTarget) {
      this.eventModalTarget.classList.add('hidden')
    }
  }
  
  // Create a new event/meeting
  createEvent(event) {
    event.preventDefault()
    
    if (!this.hasEventTitleTarget || !this.hasEventDateTarget || !this.hasEventTimeTarget ||
        !this.hasEventDurationTarget || !this.hasEventTypeTarget) {
      return
    }
    
    // Get the form values
    const title = this.eventTitleTarget.value
    const date = this.eventDateTarget.value
    const time = this.eventTimeTarget.value
    const duration = this.eventDurationTarget.value
    const type = this.eventTypeTarget.value
    const notes = this.hasEventNotesTarget ? this.eventNotesTarget.value : ''
    
    // Generate a unique ID for the event
    const id = Date.now()
    
    // Determine color based on event type
    const colors = {
      demo: 'bg-amber-100 text-amber-600',
      support: 'bg-indigo-100 text-indigo-600',
      customization: 'bg-red-100 text-red-600',
      delivery: 'bg-green-100 text-green-600',
      training: 'bg-purple-100 text-purple-600',
      other: 'bg-gray-100 text-gray-600'
    }
    
    // Get initials based on event type
    const initials = {
      demo: 'PD',
      support: 'CS',
      customization: 'PC',
      delivery: 'DL',
      training: 'TR',
      other: 'OT'
    }
    
    // Create the new event
    const newEvent = {
      id,
      title,
      date,
      time: `${time} - ${this.calculateEndTime(time, duration)}`,
      initials: initials[type],
      color: colors[type],
      notes,
      type
    }
    
    // Add the event to the events array
    if (!this.hasEventsValue) {
      this.eventsValue = []
    }
    
    this.eventsValue = [...this.eventsValue, newEvent]
    
    // Update the calendar to show the new event
    this.renderCalendar()
    
    // Update the events list if the day is selected
    if (date === this.selectedDateValue) {
      this.updateMeetingsList(date)
    }
    
    // Close the modal
    this.closeNewEventModal()
    
    // Show success toast
    this.showToast('Event Created', 'Your event has been successfully created.')
    
    // Reset the form
    if (this.hasEventTitleTarget) this.eventTitleTarget.value = ''
    if (this.hasEventNotesTarget) this.eventNotesTarget.value = ''
  }
  
  // Calculate end time based on start time and duration
  calculateEndTime(startTime, durationMinutes) {
    const [hours, minutes] = startTime.split(':').map(Number)
    const startDate = new Date()
    startDate.setHours(hours, minutes, 0)
    
    const endDate = new Date(startDate.getTime() + parseInt(durationMinutes) * 60000)
    const endHours = endDate.getHours()
    const endMinutes = endDate.getMinutes()
    
    return `${endHours.toString().padStart(2, '0')}:${endMinutes.toString().padStart(2, '0')}`
  }
  
  // Show toast notification
  showToast(title, message) {
    if (!this.hasToastTarget || !this.hasToastTitleTarget || !this.hasToastMessageTarget) return
    
    // Set toast content
    this.toastTitleTarget.textContent = title
    this.toastMessageTarget.textContent = message
    
    // Show the toast
    this.toastTarget.classList.remove('hidden')
    
    // Trigger animation
    setTimeout(() => {
      this.toastTarget.classList.remove('opacity-0', 'translate-y-2')
      this.toastTarget.classList.add('opacity-100', 'translate-y-0')
    }, 10)
    
    // Auto-hide after 5 seconds
    this.toastTimeout = setTimeout(() => {
      this.hideToast()
    }, 5000)
  }
  
  // Hide toast notification
  hideToast() {
    if (!this.hasToastTarget) return
    
    // Clear any existing timeout
    if (this.toastTimeout) {
      clearTimeout(this.toastTimeout)
      this.toastTimeout = null
    }
    
    // Trigger hide animation
    this.toastTarget.classList.add('opacity-0', 'translate-y-2')
    this.toastTarget.classList.remove('opacity-100', 'translate-y-0')
    
    // Hide after animation completes
    setTimeout(() => {
      this.toastTarget.classList.add('hidden')
    }, 300)
  }
  
  // Open event details modal
  openEventDetailsModal(event) {
    if (!this.hasEventDetailsModalTarget) return
    
    const eventId = event.currentTarget.dataset.eventId
    const eventData = this.getEventById(eventId)
    
    if (!eventData) return
    
    // Populate modal with event details
    if (this.hasEventDetailsTitleTarget) {
      this.eventDetailsTitleTarget.textContent = eventData.title
    }
    
    if (this.hasEventDetailsDateTarget) {
      // Format date nicely
      const dateObj = new Date(eventData.date)
      const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
      this.eventDetailsDateTarget.textContent = dateObj.toLocaleDateString(undefined, options)
    }
    
    if (this.hasEventDetailsTimeTarget) {
      this.eventDetailsTimeTarget.textContent = eventData.time
    }
    
    if (this.hasEventDetailsTypeTarget) {
      const eventTypeLabels = {
        demo: 'Product Demo',
        support: 'Customer Support',
        customization: 'Product Customization',
        delivery: 'Product Delivery',
        training: 'Training Session',
        other: 'Other'
      }
      this.eventDetailsTypeTarget.textContent = eventTypeLabels[eventData.type] || 'Event'
    }
    
    if (this.hasEventDetailsNotesTarget) {
      this.eventDetailsNotesTarget.textContent = eventData.notes || 'No additional notes for this event.'
    }
    
    if (this.hasEventDetailsAvatarTarget) {
      // Create avatar for event
      this.eventDetailsAvatarTarget.innerHTML = `
        <div class="w-10 h-10 rounded-full ${eventData.color} flex items-center justify-center">
          <span class="text-sm font-medium">${eventData.initials}</span>
        </div>
      `
    }
    
    // Store current event ID for edit/delete operations
    this.currentEventId = eventId
    
    // Show the modal
    this.eventDetailsModalTarget.classList.remove('hidden')
  }
  
  // Close event details modal
  closeEventDetailsModal() {
    if (this.hasEventDetailsModalTarget) {
      this.eventDetailsModalTarget.classList.add('hidden')
    }
  }
  
  // Delete event
  deleteEvent() {
    if (!this.currentEventId) return
    
    // Find the event in the events array
    const eventIndex = this.eventsValue.findIndex(event => event.id.toString() === this.currentEventId.toString())
    
    if (eventIndex === -1) return
    
    // Get event data for notification
    const eventData = this.eventsValue[eventIndex]
    
    // Remove the event from the array
    this.eventsValue = this.eventsValue.filter(event => event.id.toString() !== this.currentEventId.toString())
    
    // Close the modal
    this.closeEventDetailsModal()
    
    // Update the calendar
    this.renderCalendar()
    
    // Update the events list if the deleted event was on the selected day
    if (eventData.date === this.selectedDateValue) {
      this.updateMeetingsList(this.selectedDateValue)
    }
    
    // Show success toast
    this.showToast('Event Deleted', 'The event has been successfully deleted.')
  }
  
  // Edit event by populating and showing the new event modal
  editEvent() {
    if (!this.currentEventId) return
    
    // Find the event in the events array
    const eventData = this.getEventById(this.currentEventId)
    
    if (!eventData) return
    
    // Close the details modal
    this.closeEventDetailsModal()
    
    // Populate the new event form with event data
    if (this.hasEventTitleTarget) {
      this.eventTitleTarget.value = eventData.title
    }
    
    if (this.hasEventDateTarget) {
      this.eventDateTarget.value = eventData.date
    }
    
    if (this.hasEventTimeTarget) {
      // Extract start time from the time string (format is "HH:MM - HH:MM")
      const startTime = eventData.time.split(' - ')[0]
      this.eventTimeTarget.value = startTime
    }
    
    if (this.hasEventTypeTarget) {
      this.eventTypeTarget.value = eventData.type
    }
    
    if (this.hasEventDurationTarget) {
      // Default to 60 minutes if we can't determine duration
      this.eventDurationTarget.value = '60'
    }
    
    if (this.hasEventNotesTarget) {
      this.eventNotesTarget.value = eventData.notes || ''
    }
    
    // Store the event ID for update operation
    this.editingEventId = this.currentEventId
    this.currentEventId = null
    
    // Show the new event modal
    this.openNewEventModal()
  }
  
  // Helper function to get event by ID
  getEventById(id) {
    if (!this.hasEventsValue) return null
    return this.eventsValue.find(event => event.id.toString() === id.toString())
  }
}