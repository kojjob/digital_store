import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileName", "preview", "currentPhoto", "removeCheckbox"]

  connect() {
    console.log("Profile upload controller connected")
    
    // Create a hidden field for removal if it doesn't exist
    this.ensureRemoveField()
    
    // Find the remove checkbox if it exists
    this.findRemoveCheckbox()
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

  findRemoveCheckbox() {
    // Find the remove checkbox if not directly targeted
    if (!this.hasRemoveCheckboxTarget) {
      this.removeCheckbox = document.querySelector('input[name="user[remove_profile_picture]"');
    } else {
      this.removeCheckbox = this.removeCheckboxTarget;
    }
  }
  
  previewImage(event) {
    const file = event.target.files[0]
    if (file) {
      this.fileNameTarget.textContent = `Selected: ${file.name}`
      
      // Create a preview if possible
      if (this.hasPreviewTarget) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.previewTarget.src = e.target.result;
          this.previewTarget.classList.remove('hidden');
          
          // Hide the current photo if it exists
          if (this.hasCurrentPhotoTarget) {
            this.currentPhotoTarget.classList.add('hidden');
          }
        };
        reader.readAsDataURL(file);
      }
      
      // Reset remove flag when selecting a new file
      if (this.removeField) {
        this.removeField.value = '0';
      }
      
      // Uncheck remove checkbox if it exists
      if (this.removeCheckbox) {
        this.removeCheckbox.checked = false;
      }
    }
  }

  removeImage() {
    this.inputTarget.value = ''
    this.fileNameTarget.textContent = 'No image selected'
    
    // Hide the preview if it exists
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add('hidden');
      this.previewTarget.src = '';
    }
    
    // Show the placeholder/initials if we have a current photo
    if (this.hasCurrentPhotoTarget) {
      this.currentPhotoTarget.classList.add('hidden');
    }
    
    // Set flag to remove the existing profile picture
    if (this.removeField) {
      this.removeField.value = '1';
    }
    
    // Check the remove checkbox if it exists
    if (this.removeCheckbox) {
      this.removeCheckbox.checked = true;
    }
  }

  displayFileName() {
    const fileName = this.inputTarget.files[0]?.name || "No file selected"
    this.fileNameTarget.textContent = fileName
  }
  
  // Debug method to help users troubleshoot profile image issues
  troubleshoot() {
    console.log('Profile image troubleshooting:\n')
    console.log('- Has profile picture field:', this.hasInputTarget)
    console.log('- Has file name field:', this.hasFileNameTarget)
    console.log('- Has preview target:', this.hasPreviewTarget)
    console.log('- Has current photo target:', this.hasCurrentPhotoTarget)
    console.log('- Has remove checkbox:', this.hasRemoveCheckboxTarget || !!this.removeCheckbox)
    console.log('- Current file selected:', this.inputTarget.files[0]?.name || 'None')
    
    if (this.hasCurrentPhotoTarget) {
      console.log('- Current photo visible:', !this.currentPhotoTarget.classList.contains('hidden'))
    }
    
    if (this.hasPreviewTarget) {
      console.log('- Preview visible:', !this.previewTarget.classList.contains('hidden'))
      console.log('- Preview has src:', !!this.previewTarget.src && this.previewTarget.src !== window.location.href)
    }
  }
}