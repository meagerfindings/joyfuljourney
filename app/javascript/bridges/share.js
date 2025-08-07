// Share Bridge Component for Turbo Native
// Handles native sharing functionality

import { BridgeComponent } from "@hotwired/turbo-native-bridge"

export default class extends BridgeComponent {
  static component = "share"
  
  connect() {
    super.connect()
    this.setupShareButtons()
  }
  
  disconnect() {
    this.teardownShareButtons()
    super.disconnect()
  }
  
  setupShareButtons() {
    // Find all share buttons or links with data-share attribute
    this.shareElements = this.element.querySelectorAll('[data-share], .share-button')
    
    this.shareElements.forEach(element => {
      element.addEventListener("click", this.handleShare)
      
      // Add visual indicator for native share capability
      if (this.isNativeApp()) {
        element.classList.add("native-share-enabled")
      }
    })
  }
  
  teardownShareButtons() {
    this.shareElements?.forEach(element => {
      element.removeEventListener("click", this.handleShare)
    })
  }
  
  handleShare = (event) => {
    event.preventDefault()
    
    const element = event.currentTarget
    const shareData = this.getShareData(element)
    
    if (this.isNativeApp()) {
      // Use native share sheet
      this.send("share", shareData)
    } else if (navigator.share) {
      // Use Web Share API if available
      navigator.share(shareData).catch(err => {
        console.log("Share cancelled or failed:", err)
      })
    } else {
      // Fallback to copying link
      this.fallbackShare(shareData)
    }
  }
  
  getShareData(element) {
    // Try to get share data from data attributes
    const title = element.dataset.shareTitle || 
                 document.querySelector('meta[property="og:title"]')?.content ||
                 document.title
    
    const text = element.dataset.shareText || 
                element.dataset.shareDescription ||
                document.querySelector('meta[property="og:description"]')?.content ||
                ""
    
    const url = element.dataset.shareUrl || 
               element.href || 
               window.location.href
    
    // Get image if available
    const image = element.dataset.shareImage ||
                 document.querySelector('meta[property="og:image"]')?.content
    
    return {
      title: title,
      text: text,
      url: url,
      image: image
    }
  }
  
  fallbackShare(shareData) {
    // Copy URL to clipboard as fallback
    if (navigator.clipboard) {
      navigator.clipboard.writeText(shareData.url).then(() => {
        this.showCopiedMessage()
      }).catch(err => {
        console.error("Failed to copy:", err)
        this.showShareModal(shareData)
      })
    } else {
      this.showShareModal(shareData)
    }
  }
  
  showCopiedMessage() {
    // Show a temporary "Link copied!" message
    const message = document.createElement("div")
    message.className = "alert alert-success position-fixed bottom-0 start-50 translate-middle-x mb-3"
    message.style.zIndex = "9999"
    message.textContent = "Link copied to clipboard!"
    
    document.body.appendChild(message)
    
    setTimeout(() => {
      message.remove()
    }, 2000)
  }
  
  showShareModal(shareData) {
    // Create a modal with share options
    const modalHtml = `
      <div class="modal fade" id="shareModal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Share</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <p>${shareData.title}</p>
              <div class="input-group">
                <input type="text" class="form-control" value="${shareData.url}" readonly id="shareUrl">
                <button class="btn btn-outline-secondary" type="button" onclick="navigator.clipboard.writeText('${shareData.url}')">
                  Copy
                </button>
              </div>
              <div class="mt-3">
                <a href="https://twitter.com/intent/tweet?url=${encodeURIComponent(shareData.url)}&text=${encodeURIComponent(shareData.title)}" 
                   target="_blank" class="btn btn-info me-2">
                  <i class="bi bi-twitter"></i> Twitter
                </a>
                <a href="https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareData.url)}" 
                   target="_blank" class="btn btn-primary me-2">
                  <i class="bi bi-facebook"></i> Facebook
                </a>
                <a href="mailto:?subject=${encodeURIComponent(shareData.title)}&body=${encodeURIComponent(shareData.url)}" 
                   class="btn btn-secondary">
                  <i class="bi bi-envelope"></i> Email
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
    
    // Remove any existing modal
    document.querySelector("#shareModal")?.remove()
    
    // Add modal to page
    document.body.insertAdjacentHTML("beforeend", modalHtml)
    
    // Show modal
    const modal = new bootstrap.Modal(document.querySelector("#shareModal"))
    modal.show()
    
    // Clean up when modal is hidden
    document.querySelector("#shareModal").addEventListener("hidden.bs.modal", (e) => {
      e.target.remove()
    })
  }
  
  isNativeApp() {
    return navigator.userAgent.includes("Turbo Native")
  }
  
  // Native can call this to share specific content
  shareContent(data) {
    if (this.isNativeApp()) {
      this.send("share", data)
    } else if (navigator.share) {
      navigator.share(data)
    } else {
      this.fallbackShare(data)
    }
  }
}