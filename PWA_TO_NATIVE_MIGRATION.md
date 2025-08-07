# PWA to Native Migration Strategy

This document outlines the strategy for migrating from Progressive Web App (PWA) to native mobile applications using Hotwire Native.

## Current State Analysis

### PWA Features (If Implemented)
- Service Worker for offline caching
- Web App Manifest for installation
- Push notifications (Web Push API)
- Background sync
- Offline data storage (IndexedDB/LocalStorage)

### Native App Features (Now Available)
- Turbo Native wrapping for iOS/Android
- Native navigation and UI elements
- Bridge components for native features
- Token-based authentication
- Secure credential storage

## Migration Strategy

### Phase 1: Feature Parity Assessment

#### Offline Functionality
**PWA Approach:**
- Service Worker caches static assets
- Cache-first or network-first strategies
- IndexedDB for offline data

**Native Approach:**
- Turbo Native automatic page caching
- WebView cache management
- Native SQLite/Core Data for offline storage

**Migration Path:**
```javascript
// Keep service worker for web users
if (!navigator.userAgent.includes("Turbo Native")) {
  // Register service worker only for web
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/service-worker.js');
  }
}
```

#### Installation & App Icons
**PWA Approach:**
- Web App Manifest
- Add to Home Screen prompt
- App icons in manifest

**Native Approach:**
- App Store/Play Store installation
- Native app icons
- Launch screens

**Migration Path:**
1. Keep manifest.json for web users
2. Update manifest to exclude native user agents
3. Provide app store download links for mobile web users

### Phase 2: Service Worker Adaptation

Create a conditional service worker that only activates for web users:

```javascript
// public/service-worker.js
self.addEventListener('install', (event) => {
  // Skip if native app
  if (self.clients.matchAll().then(clients => 
    clients.some(client => client.url.includes('turbo-native')))) {
    return;
  }
  
  event.waitUntil(
    caches.open('v1').then((cache) => {
      return cache.addAll([
        '/',
        '/offline.html',
        '/assets/application.css',
        '/assets/application.js'
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  // Let native app handle its own caching
  if (event.request.headers.get('User-Agent')?.includes('Turbo Native')) {
    return;
  }
  
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
```

### Phase 3: Push Notifications Migration

#### Web Push to Native Push

**PWA Implementation:**
```javascript
// Request permission
Notification.requestPermission().then(permission => {
  if (permission === 'granted') {
    // Subscribe to push service
  }
});
```

**Native Implementation:**
```swift
// iOS - AppDelegate.swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
  if granted {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
}
```

```kotlin
// Android - MainActivity.kt
private fun setupPushNotifications() {
    FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
        if (task.isSuccessful) {
            val token = task.result
            // Send token to server
        }
    }
}
```

### Phase 4: Data Sync Strategy

#### Offline Data Handling

**Web Approach:**
```javascript
// Using IndexedDB for offline storage
const db = await openDB('JoyfulJourney', 1, {
  upgrade(db) {
    db.createObjectStore('posts');
    db.createObjectStore('drafts');
  }
});

// Save draft offline
await db.put('drafts', postData, postId);
```

**Native Approach:**
```swift
// iOS - Core Data for offline storage
let context = persistentContainer.viewContext
let draft = PostDraft(context: context)
draft.title = title
draft.body = body
draft.createdAt = Date()

do {
    try context.save()
} catch {
    print("Failed to save draft: \(error)")
}
```

### Phase 5: Progressive Enhancement

Keep PWA features for web users while native apps use native features:

```erb
<!-- app/views/layouts/application.html.erb -->
<% unless turbo_native_app? %>
  <!-- PWA features for web only -->
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="#000000">
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/service-worker.js');
    }
  </script>
<% end %>
```

## Implementation Checklist

### Immediate Actions
- [x] Conditional service worker registration
- [x] Update manifest.json for web-only
- [x] Add app store links to web version
- [ ] Implement offline page for web users

### Short-term (1-2 weeks)
- [ ] Migrate push notifications to native
- [ ] Implement native offline storage
- [ ] Add background sync for native apps
- [ ] Update user onboarding flows

### Medium-term (1 month)
- [ ] Remove PWA prompts for native users
- [ ] Optimize caching strategies
- [ ] Implement native share targets
- [ ] Add native widgets (iOS/Android)

### Long-term (3 months)
- [ ] Full feature parity audit
- [ ] Performance optimization
- [ ] Native-specific features
- [ ] Sunset PWA features if needed

## User Communication Strategy

### For Existing PWA Users

1. **In-App Messaging:**
```html
<div class="native-app-prompt" data-controller="app-prompt">
  <h3>Get the Native App!</h3>
  <p>For the best experience, download our native app:</p>
  <a href="https://apps.apple.com/app/joyfuljourney" class="btn-ios">
    Download for iOS
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.joyfuljourney" class="btn-android">
    Download for Android
  </a>
  <button data-action="click->app-prompt#dismiss">Continue with Web</button>
</div>
```

2. **Email Campaign:**
- Announce native apps availability
- Highlight new features
- Provide migration instructions

3. **Feature Comparison:**

| Feature | PWA | Native App |
|---------|-----|------------|
| Offline Access | ✓ Limited | ✓ Full |
| Push Notifications | ✓ | ✓ Enhanced |
| Camera Access | ✓ Limited | ✓ Full |
| Performance | Good | Excellent |
| App Store Presence | ✗ | ✓ |
| Background Sync | Limited | ✓ Full |
| Native Share | ✗ | ✓ |
| Biometric Auth | ✗ | ✓ |

## Metrics & Monitoring

### Track Migration Success

```ruby
# app/controllers/application_controller.rb
after_action :track_platform_usage

def track_platform_usage
  platform = if turbo_native_ios?
    'ios_native'
  elsif turbo_native_android?
    'android_native'
  elsif request.headers['X-PWA-Mode']
    'pwa'
  else
    'web'
  end
  
  Analytics.track(
    event: 'platform_usage',
    properties: {
      platform: platform,
      user_id: current_user&.id,
      path: request.path
    }
  )
end
```

### KPIs to Monitor
1. PWA → Native migration rate
2. Feature usage by platform
3. Performance metrics (load time, offline usage)
4. User retention by platform
5. App store ratings and reviews

## Rollback Plan

If native apps have issues, maintain PWA functionality:

1. Keep service worker updated
2. Maintain manifest.json
3. Continue PWA feature support for 6 months
4. Monitor user feedback
5. Gradual feature deprecation

## Conclusion

The migration from PWA to native apps should be gradual and user-friendly. By maintaining both approaches initially, users can choose their preferred experience while we gather data to optimize the native apps. The goal is to eventually provide superior native experiences while keeping the web app functional for users who prefer browser-based access.