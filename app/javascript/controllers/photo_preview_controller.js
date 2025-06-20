import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["previews"]

  preview(event) {
    this.previewsTarget.innerHTML = ""
    const files = event.target.files

    Array.from(files).forEach((file, index) => {
      if (file.type.startsWith('image/')) {
        const reader = new FileReader()
        
        reader.onload = (e) => {
          const col = document.createElement('div')
          col.className = 'col-6 col-md-4 col-lg-3'
          
          const img = document.createElement('img')
          img.src = e.target.result
          img.className = 'img-thumbnail'
          img.style.maxHeight = '200px'
          img.style.objectFit = 'cover'
          
          col.appendChild(img)
          this.previewsTarget.appendChild(col)
        }
        
        reader.readAsDataURL(file)
      }
    })
  }
}