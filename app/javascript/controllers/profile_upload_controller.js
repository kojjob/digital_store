import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileName"]

  connect() {
    console.log("Profile upload controller connected")
    
    // Create a hidden field for removal if it doesn't exist
    this.ensureRemoveField()
  }
  
  ensureRemoveField() {
    const formEl = this.element.closest('form')
    if (formEl) {
      this.removeField = document.getElementById('remove_profile_picture')
      if (!this.removeField) {
        this.removeField = document.createElement('input')
        this.removeField.type = 'hidden'
        this.removeField.id = 'remove_profile_picture'
        this.removeField.name = 'user[remove_profile_picture]'
        this.removeField.value = '0'
        formEl.appendChild(this.removeField)
      }
    }
  }

  triggerFileInput(event) {
    this.inputTarget.click()
  }

  previewImage(event) {
    const file = event.target.files[0]
    if (file) {
      this.fileNameTarget.textContent = `Selected: ${file.name}`
      
      // Reset remove flag when selecting a new file
      if (this.removeField) {
        this.removeField.value = '0'
      }
    }
  }

  removeImage() {
    this.inputTarget.value = ''
    this.fileNameTarget.textContent = 'No image selected'
    
    // Set flag to remove the existing profile picture
    if (this.removeField) {
      this.removeField.value = '1'
    }
  }

  displayFileName() {
    const fileName = this.inputTarget.files[0]?.name || "No file selected"
    this.fileNameTarget.textContent = fileName
  }
}