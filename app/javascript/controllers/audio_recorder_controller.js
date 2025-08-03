import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["recordButton", "playButton", "timer", "timerText", "fileInput", "previews"]
  
  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.recordedBlob = null
    this.isRecording = false
    this.startTime = null
    this.timerInterval = null
  }

  async toggleRecording() {
    if (this.isRecording) {
      this.stopRecording()
    } else {
      await this.startRecording()
    }
  }

  async startRecording() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.mediaRecorder = new MediaRecorder(stream)
      this.audioChunks = []

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      }

      this.mediaRecorder.onstop = () => {
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
        this.recordedBlob = audioBlob
        this.createAudioPreview(audioBlob)
        this.addBlobToFileInput(audioBlob)
        
        // Stop all tracks to release the microphone
        stream.getTracks().forEach(track => track.stop())
      }

      this.mediaRecorder.start()
      this.isRecording = true
      this.startTime = Date.now()
      this.updateUI()
      this.startTimer()
    } catch (error) {
      console.error('Error accessing microphone:', error)
      alert('Unable to access microphone. Please ensure you have granted permission.')
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
      this.mediaRecorder.stop()
      this.isRecording = false
      this.stopTimer()
      this.updateUI()
    }
  }

  playRecording() {
    if (this.recordedBlob) {
      const audio = new Audio(URL.createObjectURL(this.recordedBlob))
      audio.play()
    }
  }

  createAudioPreview(blob) {
    const audioContainer = document.createElement('div')
    audioContainer.className = 'd-flex align-items-center gap-2 mb-2'
    
    const audio = document.createElement('audio')
    audio.controls = true
    audio.className = 'flex-grow-1'
    audio.src = URL.createObjectURL(blob)
    
    const removeButton = document.createElement('button')
    removeButton.type = 'button'
    removeButton.className = 'btn btn-sm btn-outline-danger'
    removeButton.innerHTML = '<i class="bi bi-trash"></i>'
    removeButton.onclick = () => {
      audioContainer.remove()
      this.recordedBlob = null
      this.playButtonTarget.classList.add('d-none')
      // Clear the file input
      const dt = new DataTransfer()
      this.fileInputTarget.files = dt.files
    }
    
    audioContainer.appendChild(audio)
    audioContainer.appendChild(removeButton)
    
    this.previewsTarget.innerHTML = ''
    this.previewsTarget.appendChild(audioContainer)
  }

  addBlobToFileInput(blob) {
    const fileName = `recording_${Date.now()}.webm`
    const file = new File([blob], fileName, { type: 'audio/webm' })
    
    const dt = new DataTransfer()
    dt.items.add(file)
    
    // Add existing files if any
    if (this.fileInputTarget.files) {
      Array.from(this.fileInputTarget.files).forEach(file => {
        dt.items.add(file)
      })
    }
    
    this.fileInputTarget.files = dt.files
  }

  updateUI() {
    if (this.isRecording) {
      this.recordButtonTarget.classList.remove('btn-outline-danger')
      this.recordButtonTarget.classList.add('btn-danger')
      this.recordButtonTarget.innerHTML = '<i class="bi bi-stop-circle me-1"></i>Stop Recording'
      this.timerTarget.classList.remove('d-none')
      this.playButtonTarget.classList.add('d-none')
    } else {
      this.recordButtonTarget.classList.remove('btn-danger')
      this.recordButtonTarget.classList.add('btn-outline-danger')
      this.recordButtonTarget.innerHTML = '<i class="bi bi-record-circle me-1"></i>Start Recording'
      this.timerTarget.classList.add('d-none')
      if (this.recordedBlob) {
        this.playButtonTarget.classList.remove('d-none')
      }
    }
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      const elapsed = Date.now() - this.startTime
      const minutes = Math.floor(elapsed / 60000)
      const seconds = Math.floor((elapsed % 60000) / 1000)
      this.timerTextTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }, 100)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  disconnect() {
    this.stopRecording()
    this.stopTimer()
  }
}