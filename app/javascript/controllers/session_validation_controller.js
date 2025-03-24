import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "password", "emailError", "passwordError", "eyeIcon", "submitButton"]

  connect() {
    console.log("Session validation controller connected")
    this.validateForm()
    
    // Add input event listeners for real-time validation
    this.emailTarget.addEventListener("input", () => {
      this.validateEmail()
      this.updateSubmitButton()
    })
    
    this.passwordTarget.addEventListener("input", () => {
      this.validatePassword()
      this.updateSubmitButton()
    })
  }
  
  validateEmail() {
    const email = this.emailTarget.value
    
    if (email.trim() === "") {
      this.showError(this.emailErrorTarget, "Email cannot be blank")
      return false
    } else {
      this.hideError(this.emailErrorTarget)
      return true
    }
  }
  
  validatePassword() {
    const password = this.passwordTarget.value
    
    if (password.trim() === "") {
      this.showError(this.passwordErrorTarget, "Password cannot be blank")
      return false
    } else {
      this.hideError(this.passwordErrorTarget)
      return true
    }
  }
  
  togglePasswordVisibility() {
    const passwordField = this.passwordTarget
    if (passwordField.type === "password") {
      passwordField.type = "text"
      this.eyeIconTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
        </svg>
      `
    } else {
      passwordField.type = "password"
      this.eyeIconTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
          <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
        </svg>
      `
    }
  }
  
  validateForm() {
    const emailValid = this.validateEmail()
    const passwordValid = this.validatePassword()
    
    return emailValid && passwordValid
  }
  
  updateSubmitButton() {
    if (this.validateForm()) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-70", "cursor-not-allowed")
      this.submitButtonTarget.classList.add("hover:bg-indigo-700")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-70", "cursor-not-allowed")
      this.submitButtonTarget.classList.remove("hover:bg-indigo-700")
    }
  }
  
  submitForm(event) {
    if (!this.validateForm()) {
      event.preventDefault()
    }
  }
  
  // Helper methods
  showError(element, message) {
    element.textContent = message
    element.classList.remove("hidden")
    const inputField = this.getInputForError(element)
    if (inputField) inputField.classList.add("border-red-500")
  }
  
  hideError(element) {
    element.classList.add("hidden")
    const inputField = this.getInputForError(element)
    if (inputField) inputField.classList.remove("border-red-500")
  }
  
  getInputForError(errorElement) {
    if (errorElement === this.emailErrorTarget) return this.emailTarget
    if (errorElement === this.passwordErrorTarget) return this.passwordTarget
    return null
  }
}