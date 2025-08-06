// Turbo Native Bridge Components Support

// Check if running in native app
window.TurboNative = {
  isNativeApp: () => {
    return navigator.userAgent.includes("Turbo Native");
  },
  
  isIOS: () => {
    return TurboNative.isNativeApp() && navigator.userAgent.includes("iOS");
  },
  
  isAndroid: () => {
    return TurboNative.isNativeApp() && navigator.userAgent.includes("Android");
  }
};

// Bridge component registration
document.addEventListener("turbo:load", () => {
  if (TurboNative.isNativeApp()) {
    // Register bridge components
    registerBridgeComponents();
    
    // Setup native-specific behaviors
    setupNativeHandlers();
  }
});

function registerBridgeComponents() {
  // Flash messages bridge
  const flashElements = document.querySelectorAll('[data-bridge-component="flash"]');
  flashElements.forEach(element => {
    const message = element.textContent.trim();
    const type = element.classList.contains('alert-success') ? 'success' : 'error';
    
    // Send to native app
    if (window.webkit?.messageHandlers?.flash) {
      window.webkit.messageHandlers.flash.postMessage({ type, message });
    } else if (window.TurboNativeBridge?.postMessage) {
      window.TurboNativeBridge.postMessage(JSON.stringify({ 
        component: 'flash',
        data: { type, message }
      }));
    }
  });
  
  // Menu component bridge
  const menuElement = document.querySelector('[data-bridge-component="menu"]');
  if (menuElement && window.webkit?.messageHandlers?.menu) {
    window.webkit.messageHandlers.menu.postMessage({ 
      items: getMenuItems() 
    });
  }
}

function setupNativeHandlers() {
  // Handle native navigation
  document.addEventListener("click", (event) => {
    const link = event.target.closest("a");
    if (link && link.dataset.turboMethod === "delete") {
      event.preventDefault();
      if (confirm("Are you sure?")) {
        // Let Turbo handle the delete
        return true;
      }
      return false;
    }
  });
  
  // Handle form submissions for native
  document.addEventListener("turbo:submit-start", (event) => {
    if (TurboNative.isNativeApp()) {
      // Add authentication token if needed
      const token = localStorage.getItem('authToken');
      if (token) {
        event.detail.formSubmission.fetchRequest.headers['Authorization'] = `Bearer ${token}`;
      }
    }
  });
}

function getMenuItems() {
  // Build menu items based on current user state
  const items = [];
  const currentUser = document.querySelector('meta[name="current-user"]');
  
  if (currentUser) {
    items.push(
      { title: "Home", path: "/" },
      { title: "Posts", path: "/posts" },
      { title: "New Post", path: "/posts/new" },
      { title: "Profile", path: `/users/${currentUser.content}` },
      { title: "Logout", path: "/logout", method: "delete" }
    );
  } else {
    items.push(
      { title: "Home", path: "/" },
      { title: "Login", path: "/login" },
      { title: "Sign Up", path: "/users/new?claimed=true" }
    );
  }
  
  return items;
}

// Export for use in other modules
export { TurboNative, registerBridgeComponents, setupNativeHandlers };