// Camera Bridge Component for Turbo Native
// Handles photo capture and gallery selection

import { BridgeComponent } from "@hotwired/turbo-native-bridge"

export default class extends BridgeComponent {
  static component = "camera"
  
  connect() {
    super.connect()
    this.setupCameraButtons()
  }
  
  disconnect() {
    this.teardownCameraButtons()
    super.disconnect()
  }
  
  setupCameraButtons() {
    // Find all file inputs that accept images
    this.fileInputs = this.element.querySelectorAll('input[type="file"][accept*="image"]')
    
    this.fileInputs.forEach(input => {
      // Hide the default file input for native
      if (this.isNativeApp()) {
        input.style.display = "none"
        this.createNativeCameraButton(input)
      }
    })
  }
  
  teardownCameraButtons() {
    // Clean up any created buttons
    const buttons = this.element.querySelectorAll(".native-camera-button")
    buttons.forEach(button => button.remove())
  }
  
  createNativeCameraButton(fileInput) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "btn btn-primary native-camera-button"
    button.innerHTML = '<i class="bi bi-camera"></i> Choose Photo'
    
    button.addEventListener("click", () => {
      this.requestPhotoSelection(fileInput)
    })
    
    // Insert button after the file input
    fileInput.parentNode.insertBefore(button, fileInput.nextSibling)
    
    // Create preview container
    const preview = document.createElement("div")
    preview.className = "photo-preview mt-2"
    preview.id = `preview-${fileInput.id}`
    button.parentNode.insertBefore(preview, button.nextSibling)
  }
  
  requestPhotoSelection(fileInput) {
    // Send request to native to show photo picker
    this.send("requestPhoto", {
      inputId: fileInput.id,
      allowsMultiple: fileInput.multiple,
      source: "both" // camera, gallery, or both
    }, (response) => {
      if (response.photos && response.photos.length > 0) {
        this.handlePhotosSelected(fileInput, response.photos)
      }
    })
  }
  
  handlePhotosSelected(fileInput, photos) {
    // Native will return photo data
    photos.forEach(photo => {
      if (photo.base64) {
        // Convert base64 to File object
        const file = this.base64ToFile(photo.base64, photo.filename)
        
        // Update the file input
        const dataTransfer = new DataTransfer()
        if (fileInput.multiple) {
          // Add to existing files if multiple
          Array.from(fileInput.files).forEach(f => dataTransfer.items.add(f))
        }
        dataTransfer.items.add(file)
        fileInput.files = dataTransfer.files
        
        // Show preview
        this.showPhotoPreview(fileInput, photo.base64)
        
        // Trigger change event
        fileInput.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })
  }
  
  showPhotoPreview(fileInput, base64Data) {
    const previewContainer = document.querySelector(`#preview-${fileInput.id}`)
    if (previewContainer) {
      const img = document.createElement("img")
      img.src = `data:image/jpeg;base64,${base64Data}`
      img.className = "img-thumbnail"
      img.style.maxWidth = "200px"
      img.style.maxHeight = "200px"
      
      // Clear previous preview if not multiple
      if (!fileInput.multiple) {
        previewContainer.innerHTML = ""
      }
      
      previewContainer.appendChild(img)
    }
  }
  
  base64ToFile(base64, filename) {
    const arr = base64.split(',')
    const mime = arr[0].match(/:(.*?);/)?.[1] || 'image/jpeg'
    const bstr = atob(arr[1] || base64)
    let n = bstr.length
    const u8arr = new Uint8Array(n)
    
    while(n--) {
      u8arr[n] = bstr.charCodeAt(n)
    }
    
    return new File([u8arr], filename || 'photo.jpg', { type: mime })
  }
  
  isNativeApp() {
    return navigator.userAgent.includes("Turbo Native")
  }
  
  // Native can call this to directly set a photo
  setPhoto(data) {
    const { inputId, base64, filename } = data
    const fileInput = document.querySelector(`#${inputId}`)
    
    if (fileInput) {
      this.handlePhotosSelected(fileInput, [{ base64, filename }])
    }
  }
}