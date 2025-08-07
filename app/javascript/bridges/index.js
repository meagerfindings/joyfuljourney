// Register all Turbo Native Bridge Components

import MenuComponent from "./menu"
import FormComponent from "./form"
import FlashComponent from "./flash"
import CameraComponent from "./camera"
import ShareComponent from "./share"

// Only register if we have the bridge available
if (window.TurboNativeBridge) {
  window.TurboNativeBridge.register(MenuComponent)
  window.TurboNativeBridge.register(FormComponent)
  window.TurboNativeBridge.register(FlashComponent)
  window.TurboNativeBridge.register(CameraComponent)
  window.TurboNativeBridge.register(ShareComponent)
}

// Export for use in application.js
export {
  MenuComponent,
  FormComponent,
  FlashComponent,
  CameraComponent,
  ShareComponent
}