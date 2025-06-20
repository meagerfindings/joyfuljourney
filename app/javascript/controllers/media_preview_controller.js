import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photoInput", "videoInput", "previews"]

  selectPhotos() {
    this.photoInputTarget.click()
  }

  selectVideos() {
    this.videoInputTarget.click()
  }

  handleFiles(event) {
    const files = event.target.files
    const isVideo = event.target === this.videoInputTarget

    Array.from(files).forEach((file, index) => {
      if (isVideo && file.type.startsWith('video/')) {
        this.createVideoPreview(file)
      } else if (!isVideo && file.type.startsWith('image/')) {
        this.createPhotoPreview(file)
      }
    })
  }

  createPhotoPreview(file) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      const col = document.createElement('div')
      col.className = 'col-6 col-md-4 col-lg-3'
      
      const wrapper = document.createElement('div')
      wrapper.className = 'position-relative'
      
      const img = document.createElement('img')
      img.src = e.target.result
      img.className = 'img-thumbnail w-100'
      img.style.height = '120px'
      img.style.objectFit = 'cover'
      
      const badge = document.createElement('span')
      badge.className = 'position-absolute top-0 end-0 badge bg-primary m-1'
      badge.innerHTML = '<i class="bi bi-image"></i>'
      
      const removeBtn = document.createElement('button')
      removeBtn.type = 'button'
      removeBtn.className = 'position-absolute top-0 start-0 btn btn-sm btn-danger m-1'
      removeBtn.innerHTML = '<i class="bi bi-x"></i>'
      removeBtn.style.padding = '0.25rem 0.5rem'
      removeBtn.onclick = () => {
        col.remove()
        this.removeFileFromInput(file, this.photoInputTarget)
      }
      
      wrapper.appendChild(img)
      wrapper.appendChild(badge)
      wrapper.appendChild(removeBtn)
      col.appendChild(wrapper)
      this.previewsTarget.appendChild(col)
    }
    
    reader.readAsDataURL(file)
  }

  createVideoPreview(file) {
    const col = document.createElement('div')
    col.className = 'col-12 col-md-6'
    
    const wrapper = document.createElement('div')
    wrapper.className = 'position-relative'
    
    const video = document.createElement('video')
    video.controls = true
    video.className = 'w-100'
    video.style.maxHeight = '200px'
    
    const source = document.createElement('source')
    source.src = URL.createObjectURL(file)
    source.type = file.type
    
    const badge = document.createElement('span')
    badge.className = 'position-absolute top-0 end-0 badge bg-primary m-1'
    badge.innerHTML = '<i class="bi bi-camera-video"></i>'
    
    const removeBtn = document.createElement('button')
    removeBtn.type = 'button'
    removeBtn.className = 'position-absolute top-0 start-0 btn btn-sm btn-danger m-1'
    removeBtn.innerHTML = '<i class="bi bi-x"></i>'
    removeBtn.style.padding = '0.25rem 0.5rem'
    removeBtn.onclick = () => {
      col.remove()
      URL.revokeObjectURL(source.src)
      this.removeFileFromInput(file, this.videoInputTarget)
    }
    
    video.appendChild(source)
    wrapper.appendChild(video)
    wrapper.appendChild(badge)
    wrapper.appendChild(removeBtn)
    col.appendChild(wrapper)
    this.previewsTarget.appendChild(col)
  }

  removeFileFromInput(fileToRemove, input) {
    const dt = new DataTransfer()
    const files = Array.from(input.files)
    
    files.forEach(file => {
      if (file !== fileToRemove) {
        dt.items.add(file)
      }
    })
    
    input.files = dt.files
  }
}