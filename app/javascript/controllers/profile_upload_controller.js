import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileName"]

  connect() {
    console.log("Profile upload controller connected")
  }

  triggerFileInput(event) {
    this.inputTarget.click()
  }

  displayFileName() {
    const fileName = this.inputTarget.files[0]?.name || "No file selected"
    this.fileNameTarget.textContent = fileName
  }
}