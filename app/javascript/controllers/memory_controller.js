import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="memory"
export default class extends Controller {
  static targets = ["form", "card", "shareButton"]
  static values = { title: String, url: String }

  connect() {
    console.log("Memory controller connected")
  }

  // Handle card hover animations
  hoverIn(event) {
    event.target.closest('.hover-card')?.classList.add('shadow-lg')
  }

  hoverOut(event) {
    event.target.closest('.hover-card')?.classList.remove('shadow-lg')
  }

  // Enhanced sharing functionality
  async share(event) {
    event.preventDefault()
    
    const shareData = {
      title: this.titleValue || 'Joyful Journey Memory',
      text: 'Check out this family memory!',
      url: this.urlValue || window.location.href
    }

    try {
      if (navigator.share) {
        await navigator.share(shareData)
      } else {
        // Fallback to clipboard
        await navigator.clipboard.writeText(shareData.url)
        this.showToast('Link copied to clipboard! 📋')
      }
    } catch (error) {
      console.log('Error sharing:', error)
      this.showToast('Unable to share at this time')
    }
  }

  // Auto-resize text areas
  autoResize(event) {
    const textarea = event.target
    textarea.style.height = 'auto'
    textarea.style.height = textarea.scrollHeight + 'px'
  }

  // Character counter for forms
  updateCharCount(event) {
    const textarea = event.target
    const maxLength = textarea.getAttribute('maxlength')
    const currentLength = textarea.value.length
    
    const counter = textarea.parentElement.querySelector('.char-counter')
    if (counter && maxLength) {
      counter.textContent = `${currentLength}/${maxLength}`
      counter.classList.toggle('text-warning', currentLength > maxLength * 0.8)
      counter.classList.toggle('text-danger', currentLength >= maxLength)
    }
  }

  // Form validation feedback
  validateForm(event) {
    const form = event.target
    const requiredFields = form.querySelectorAll('[required]')
    let isValid = true

    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        field.classList.add('is-invalid')
        isValid = false
      } else {
        field.classList.remove('is-invalid')
        field.classList.add('is-valid')
      }
    })

    return isValid
  }

  // Show toast notification
  showToast(message, type = 'success') {
    const toast = document.createElement('div')
    toast.className = `toast align-items-center text-white bg-${type} border-0`
    toast.setAttribute('role', 'alert')
    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">${message}</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    `

    const container = document.querySelector('.toast-container') || document.body
    container.appendChild(toast)

    const bsToast = new bootstrap.Toast(toast)
    bsToast.show()

    toast.addEventListener('hidden.bs.toast', () => toast.remove())
  }

  // Smooth scroll to element
  scrollTo(event) {
    event.preventDefault()
    const target = document.querySelector(event.target.getAttribute('href'))
    if (target) {
      target.scrollIntoView({ behavior: 'smooth' })
    }
  }
}