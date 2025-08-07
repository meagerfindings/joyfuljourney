// Menu Bridge Component for Turbo Native
// Handles native menu/navigation actions

import { BridgeComponent } from "@hotwired/turbo-native-bridge"

export default class extends BridgeComponent {
  static component = "menu"
  
  connect() {
    super.connect()
    this.notifyNativeOfMenuItems()
  }
  
  notifyNativeOfMenuItems() {
    const menuItems = this.getMenuItems()
    this.send("updateMenuItems", { items: menuItems })
  }
  
  getMenuItems() {
    const items = []
    const currentUser = this.getCurrentUser()
    
    if (currentUser) {
      items.push(
        { id: "home", title: "Home", path: "/", icon: "house" },
        { id: "posts", title: "Posts", path: "/posts", icon: "doc.text" },
        { id: "new_post", title: "New Post", path: "/posts/new", icon: "plus.circle" },
        { id: "timeline", title: "Timeline", path: "/timeline", icon: "clock" },
        { id: "families", title: "Families", path: "/families", icon: "person.3" },
        { id: "profile", title: "Profile", path: `/users/${currentUser.id}`, icon: "person" },
        { type: "separator" },
        { id: "logout", title: "Logout", path: "/logout", method: "post", icon: "arrow.right.square" }
      )
      
      // Add admin items if user is admin
      if (currentUser.role === "admin" || currentUser.role === "manager") {
        items.splice(6, 0, 
          { type: "separator" },
          { id: "users", title: "Manage Users", path: "/users", icon: "person.2" }
        )
      }
    } else {
      items.push(
        { id: "home", title: "Home", path: "/", icon: "house" },
        { id: "login", title: "Login", path: "/login", icon: "arrow.right.square" },
        { id: "signup", title: "Sign Up", path: "/users/new?claimed=true", icon: "person.badge.plus" }
      )
    }
    
    return items
  }
  
  getCurrentUser() {
    const userMeta = document.querySelector('meta[name="current-user-data"]')
    if (userMeta && userMeta.content) {
      try {
        return JSON.parse(userMeta.content)
      } catch (e) {
        console.error("Error parsing current user data:", e)
      }
    }
    return null
  }
  
  // Handle menu item selection from native
  selectMenuItem(data) {
    const { itemId, path, method } = data
    
    if (method === "post") {
      // Create a form and submit it for POST requests
      const form = document.createElement("form")
      form.method = "post"
      form.action = path
      
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      
      form.appendChild(csrfInput)
      document.body.appendChild(form)
      form.submit()
    } else {
      // Use Turbo for navigation
      window.Turbo.visit(path)
    }
  }
}