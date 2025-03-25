import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "firstName", "lastName", "email", "password", "passwordConfirmation", 
    "firstNameError", "lastNameError", "emailError", "passwordError", "passwordConfirmationError",
    "eyeIcon", "passwordStrength", "passwordStrengthBar", "passwordStrengthText"
  ]

  connect() {
    console.log("Registration validation controller connected")
  }

  validateName(event) {
    const field = event.target
    const fieldName = field.id.includes("first_name") ? "firstName" : "lastName"
    const errorTarget = this[`${fieldName}ErrorTarget`]
    
    if (field.value.trim() === "") {
      errorTarget.textContent = `${fieldName === "firstName" ? "First" : "Last"} name cannot be blank`
      errorTarget.classList.remove("hidden")
      field.classList.add("border-red-500")
      return false
    } else {
      errorTarget.classList.add("hidden")
      field.classList.remove("border-red-500")
      return true
    }
  }

  validateEmail() {
    const email = this.emailTarget.value
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    
    if (email.trim() === "") {
      this.emailErrorTarget.textContent = "Email cannot be blank"
      this.emailErrorTarget.classList.remove("hidden")
      this.emailTarget.classList.add("border-red-500")
      return false
    } else if (!emailRegex.test(email)) {
      this.emailErrorTarget.textContent = "Please enter a valid email address"
      this.emailErrorTarget.classList.remove("hidden")
      this.emailTarget.classList.add("border-red-500")
      return false
    } else {
      this.emailErrorTarget.classList.add("hidden")
      this.emailTarget.classList.remove("border-red-500")
      return true
    }
  }

  validatePassword() {
    const password = this.passwordTarget.value
    const minLength = parseInt(document.getElementById("password-description")?.textContent.match(/\d+/)?.[0] || 6)
    
    // Calculate password strength
    let strength = 0
    let validations = []
    
    if (password.length >= minLength) strength += 25
    else validations.push(`Password must be at least ${minLength} characters`)
    
    if (password.match(/[a-z]+/)) strength += 25
    else validations.push("Include at least one lowercase letter")
    
    if (password.match(/[A-Z]+/)) strength += 25
    else validations.push("Include at least one uppercase letter")
    
    if (password.match(/[0-9]+/)) strength += 15
    else validations.push("Include at least one number")
    
    if (password.match(/[^a-zA-Z0-9]+/)) strength += 10
    else validations.push("Include at least one special character")
    
    // Update strength bar if it exists
    if (this.hasPasswordStrengthBarTarget) {
      this.passwordStrengthBarTarget.style.width = `${strength}%`
      
      // Update color and text
      this.passwordStrengthBarTarget.classList.remove("bg-red-500", "bg-yellow-500", "bg-green-500")
      
      if (strength < 30) {
        this.passwordStrengthBarTarget.classList.add("bg-red-500")
        this.passwordStrengthTextTarget.textContent = "Weak"
      } else if (strength < 70) {
        this.passwordStrengthBarTarget.classList.add("bg-yellow-500")
        this.passwordStrengthTextTarget.textContent = "Medium"
      } else {
        this.passwordStrengthBarTarget.classList.add("bg-green-500")
        this.passwordStrengthTextTarget.textContent = "Strong"
      }
    }
    
    if (password.length < minLength) {
      this.passwordErrorTarget.textContent = validations[0]
      this.passwordErrorTarget.classList.remove("hidden")
      this.passwordTarget.classList.add("border-red-500")
      return false
    } else {
      this.passwordErrorTarget.classList.add("hidden")
      this.passwordTarget.classList.remove("border-red-500")
      return true
    }
  }

  validatePasswordConfirmation() {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value
    
    if (password !== confirmation) {
      this.passwordConfirmationErrorTarget.textContent = "Passwords don't match"
      this.passwordConfirmationErrorTarget.classList.remove("hidden")
      this.passwordConfirmationTarget.classList.add("border-red-500")
      return false
    } else {
      this.passwordConfirmationErrorTarget.classList.add("hidden")
      this.passwordConfirmationTarget.classList.remove("border-red-500")
      return true
    }
  }

  validateForm(event) {
    const nameValid = this.validateName({ target: this.firstNameTarget }) && 
                     this.validateName({ target: this.lastNameTarget })
    const emailValid = this.validateEmail()
    const passwordValid = this.validatePassword()
    const confirmationValid = this.validatePasswordConfirmation()
    
    if (!(nameValid && emailValid && passwordValid && confirmationValid)) {
      event.preventDefault()
    }
  }

  togglePasswordVisibility() {
    const passwordField = this.passwordTarget
    if (passwordField.type === "password") {
      passwordField.type = "text"
      this.eyeIconTarget.innerHTML = `
        <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd" />
        <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
      `
    } else {
      passwordField.type = "password"
      this.eyeIconTarget.innerHTML = `
        <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
        <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
      `
    }
  }
}