import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["previews"]

  preview(event) {
    this.previewsTarget.innerHTML = ""
    const files = event.target.files

    Array.from(files).forEach((file, index) => {
      if (file.type.startsWith('video/')) {
        const col = document.createElement('div')
        col.className = 'col-12 col-md-6'
        
        const video = document.createElement('video')
        video.controls = true
        video.className = 'w-100'
        video.style.maxHeight = '200px'
        
        const source = document.createElement('source')
        source.src = URL.createObjectURL(file)
        source.type = file.type
        
        video.appendChild(source)
        col.appendChild(video)
        this.previewsTarget.appendChild(col)
      }
    })
  }
}