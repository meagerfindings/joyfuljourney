// Form Bridge Component for Turbo Native
// Handles form interactions and native keyboard management

import { BridgeComponent } from "@hotwired/turbo-native-bridge"

export default class extends BridgeComponent {
  static component = "form"
  
  connect() {
    super.connect()
    this.setupFormListeners()
  }
  
  disconnect() {
    this.teardownFormListeners()
    super.disconnect()
  }
  
  setupFormListeners() {
    this.element.addEventListener("focus", this.handleFocus, true)
    this.element.addEventListener("blur", this.handleBlur, true)
    this.element.addEventListener("submit", this.handleSubmit)
    
    // Watch for form validation
    const inputs = this.element.querySelectorAll("input, textarea, select")
    inputs.forEach(input => {
      input.addEventListener("invalid", this.handleInvalid)
      input.addEventListener("input", this.handleInput)
    })
  }
  
  teardownFormListeners() {
    this.element.removeEventListener("focus", this.handleFocus, true)
    this.element.removeEventListener("blur", this.handleBlur, true)
    this.element.removeEventListener("submit", this.handleSubmit)
  }
  
  handleFocus = (event) => {
    if (this.isFormField(event.target)) {
      this.send("formFieldFocused", {
        fieldName: event.target.name,
        fieldType: event.target.type,
        fieldId: event.target.id
      })
    }
  }
  
  handleBlur = (event) => {
    if (this.isFormField(event.target)) {
      this.send("formFieldBlurred", {
        fieldName: event.target.name,
        fieldType: event.target.type,
        fieldId: event.target.id
      })
    }
  }
  
  handleSubmit = (event) => {
    const form = event.target
    
    // Check if form is valid
    if (!form.checkValidity()) {
      event.preventDefault()
      this.send("formValidationFailed", {
        errors: this.getValidationErrors(form)
      })
      return
    }
    
    // Notify native that form is being submitted
    this.send("formSubmitting", {
      action: form.action,
      method: form.method
    })
  }
  
  handleInvalid = (event) => {
    const field = event.target
    this.send("fieldValidationFailed", {
      fieldName: field.name,
      fieldId: field.id,
      message: field.validationMessage
    })
  }
  
  handleInput = (event) => {
    const field = event.target
    
    // Clear validation error when user starts typing
    if (field.classList.contains("is-invalid")) {
      field.classList.remove("is-invalid")
      const errorElement = field.parentElement.querySelector(".invalid-feedback")
      if (errorElement) {
        errorElement.remove()
      }
    }
    
    // Notify native of input changes for real-time validation
    this.send("fieldChanged", {
      fieldName: field.name,
      fieldId: field.id,
      value: field.value,
      valid: field.checkValidity()
    })
  }
  
  isFormField(element) {
    return ["INPUT", "TEXTAREA", "SELECT"].includes(element.tagName)
  }
  
  getValidationErrors(form) {
    const errors = []
    const fields = form.querySelectorAll("input, textarea, select")
    
    fields.forEach(field => {
      if (!field.checkValidity()) {
        errors.push({
          fieldName: field.name,
          fieldId: field.id,
          message: field.validationMessage
        })
      }
    })
    
    return errors
  }
  
  // Native can call this to programmatically submit the form
  submitForm() {
    const form = this.element.querySelector("form")
    if (form) {
      form.submit()
    }
  }
  
  // Native can call this to set field values
  setFieldValue(data) {
    const { fieldId, value } = data
    const field = this.element.querySelector(`#${fieldId}`)
    if (field) {
      field.value = value
      field.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }
}