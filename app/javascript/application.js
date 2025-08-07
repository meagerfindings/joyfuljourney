// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Turbo Native support if running in native app
if (navigator.userAgent.includes("Turbo Native")) {
  import("./turbo_native")
  import("./bridges")
}

// Add current user meta tag for bridge components
document.addEventListener("turbo:load", () => {
  updateCurrentUserMeta()
})

function updateCurrentUserMeta() {
  // Get current user data from DOM if available
  const userElement = document.querySelector('[data-current-user]')
  if (userElement) {
    let metaTag = document.querySelector('meta[name="current-user-data"]')
    if (!metaTag) {
      metaTag = document.createElement('meta')
      metaTag.name = 'current-user-data'
      document.head.appendChild(metaTag)
    }
    metaTag.content = userElement.dataset.currentUser
  }
}