// Flash Bridge Component for Turbo Native
// Handles flash messages and native alerts/toasts

import { BridgeComponent } from "@hotwired/turbo-native-bridge"

export default class extends BridgeComponent {
  static component = "flash"
  
  connect() {
    super.connect()
    this.notifyNativeOfFlashMessage()
  }
  
  notifyNativeOfFlashMessage() {
    const message = this.element.textContent.trim()
    const type = this.getFlashType()
    
    if (message) {
      // Send to native for display as toast/alert
      this.send("displayFlashMessage", {
        message: message,
        type: type,
        duration: this.getDuration(type)
      })
      
      // Optionally hide the web flash for native apps
      if (this.shouldHideWebFlash()) {
        this.element.style.display = "none"
      }
    }
  }
  
  getFlashType() {
    const classList = this.element.classList
    
    if (classList.contains("alert-success")) return "success"
    if (classList.contains("alert-danger")) return "error"
    if (classList.contains("alert-warning")) return "warning"
    if (classList.contains("alert-info")) return "info"
    
    return "info"
  }
  
  getDuration(type) {
    // Different durations based on message type
    switch(type) {
      case "error":
        return 5000 // Show errors longer
      case "warning":
        return 4000
      case "success":
        return 3000
      default:
        return 3000
    }
  }
  
  shouldHideWebFlash() {
    // Hide web flash messages in native apps to avoid duplication
    return navigator.userAgent.includes("Turbo Native")
  }
  
  // Native can call this to display a flash message from native code
  displayWebFlash(data) {
    const { message, type } = data
    
    const flashContainer = document.querySelector("#flash-messages") || 
                          document.querySelector(".toast-container")
    
    if (flashContainer) {
      const alertClass = type === "success" ? "alert-success" : 
                        type === "error" ? "alert-danger" :
                        type === "warning" ? "alert-warning" : "alert-info"
      
      const flashElement = document.createElement("div")
      flashElement.className = `alert ${alertClass} alert-dismissible fade show m-3`
      flashElement.setAttribute("role", "alert")
      flashElement.setAttribute("data-turbo-temporary", "true")
      flashElement.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      `
      
      flashContainer.appendChild(flashElement)
      
      // Auto-dismiss after duration
      setTimeout(() => {
        flashElement.classList.remove("show")
        setTimeout(() => flashElement.remove(), 150)
      }, this.getDuration(type))
    }
  }
}