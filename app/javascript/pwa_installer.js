// PWA Install Prompt Handler
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent Chrome 67 and earlier from automatically showing the prompt
  e.preventDefault();
  // Stash the event so it can be triggered later
  deferredPrompt = e;
  
  // Show install button if not already installed
  const installButton = document.getElementById('install-app-button');
  if (installButton) {
    installButton.style.display = 'block';
    installButton.addEventListener('click', handleInstallClick);
  }
});

function handleInstallClick() {
  const installButton = document.getElementById('install-app-button');
  if (installButton) {
    installButton.style.display = 'none';
  }
  
  // Show the install prompt
  if (deferredPrompt) {
    deferredPrompt.prompt();
    
    // Wait for the user to respond to the prompt
    deferredPrompt.userChoice.then((choiceResult) => {
      if (choiceResult.outcome === 'accepted') {
        console.log('User accepted the install prompt');
      } else {
        console.log('User dismissed the install prompt');
      }
      deferredPrompt = null;
    });
  }
}

// Listen for successful install
window.addEventListener('appinstalled', () => {
  console.log('PWA was installed');
  // Hide install button
  const installButton = document.getElementById('install-app-button');
  if (installButton) {
    installButton.style.display = 'none';
  }
});

// Check if app is installed
if (window.matchMedia('(display-mode: standalone)').matches) {
  console.log('App is running in standalone mode');
}