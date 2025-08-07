# JoyfulJourney Android App

Native Android shell for the JoyfulJourney Rails application using Turbo Android.

## Requirements

- Android Studio Hedgehog (2023.1.1) or later
- Android SDK 34
- Kotlin 1.9+
- Minimum Android API 24 (Android 7.0)

## Setup

### 1. Create Android Project

1. Open Android Studio
2. Create New Project → Empty Activity
3. Name: `JoyfulJourney`
4. Package: `com.joyfuljourney`
5. Language: Kotlin
6. Minimum SDK: API 24

### 2. Add Dependencies

Copy the `build.gradle` file to your `app/` directory, or add these dependencies:

```gradle
dependencies {
    // Turbo Android
    implementation 'dev.hotwire:turbo:7.1.3'
    
    // Material Design
    implementation 'com.google.android.material:material:1.11.0'
    
    // Navigation
    implementation 'androidx.navigation:navigation-fragment-ktx:2.7.6'
    implementation 'androidx.navigation:navigation-ui-ktx:2.7.6'
    
    // Security for encrypted preferences
    implementation 'androidx.security:security-crypto:1.1.0-alpha06'
    
    // Network
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
}
```

### 3. Add Project Files

Copy these Kotlin files to `app/src/main/java/com/joyfuljourney/`:

- `MainActivity.kt` - Main activity with bottom navigation
- `JoyfulJourneyApplication.kt` - Application class with Turbo config
- `AuthenticationManager.kt` - Authentication and token management

### 4. Configure AndroidManifest.xml

Add to your manifest:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Application name -->
<application
    android:name=".JoyfulJourneyApplication"
    android:usesCleartextTraffic="true">  <!-- For local development -->
    ...
</application>
```

### 5. Configure Server URL

Update the server URL in `app/build.gradle`:

```gradle
buildTypes {
    debug {
        buildConfigField "String", "BASE_URL", '"http://10.0.2.2:3000"'  // Emulator localhost
    }
    release {
        buildConfigField "String", "BASE_URL", '"https://joyfuljourney.com"'
    }
}
```

For physical devices, use your computer's IP address instead of `10.0.2.2`.

## Features

### Authentication
- Encrypted token storage using EncryptedSharedPreferences
- Automatic token injection into WebView
- Login/logout flow with Retrofit API calls

### Navigation
- Bottom navigation with 5 main sections
- Modal presentation for forms
- Path configuration loaded from server
- Pull-to-refresh support

### Bridge Components (To be implemented)

Create these in `app/src/main/java/com/joyfuljourney/bridges/`:

#### MenuBridge
- Native menu options
- Contextual actions

#### CameraBridge
- Camera capture using CameraX
- Gallery selection
- Image compression

#### FlashBridge
- Toast notifications
- Snackbar messages

#### ShareBridge
- Native share intent
- Social media integration

#### FormBridge
- Keyboard management
- Input validation

## Development

### Running Locally

1. Start your Rails server:
```bash
rails server -b 0.0.0.0  # Bind to all interfaces
```

2. If using emulator:
   - Server URL: `http://10.0.2.2:3000`
   
3. If using physical device:
   - Find your computer's IP: `ifconfig` or `ipconfig`
   - Server URL: `http://YOUR_IP:3000`
   - Ensure device and computer are on same network

4. Build and run in Android Studio (Shift+F10)

### Testing Authentication

1. Create a user in your Rails app
2. Launch the Android app
3. Login with the user credentials
4. Token will be stored in encrypted preferences

### Debugging

Enable Turbo debugging in `JoyfulJourneyApplication.kt`:

```kotlin
TurboConfig.debugLoggingEnabled = BuildConfig.DEBUG
```

Use Logcat to monitor:
- Navigation events
- Bridge messages
- Network requests
- WebView console logs

### Network Security

For production, remove `android:usesCleartextTraffic="true"` and use HTTPS only.

For development with custom domains, add network security config:

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">YOUR_LOCAL_IP</domain>
    </domain-config>
</network-security-config>
```

## Architecture

### Application Structure
- `JoyfulJourneyApplication`: Initializes Turbo and authentication
- `MainActivity`: Hosts bottom navigation and fragments
- `AuthenticationManager`: Handles login/logout and token storage

### Navigation Flow
1. App launches → Check authentication
2. If not authenticated → Show login
3. Path configuration determines navigation behavior
4. Bottom navigation switches between main sections

### Data Flow
1. User navigates → Path configuration consulted
2. WebView loads → Bridge components register
3. JavaScript events → Native handlers respond
4. Native actions → JavaScript callbacks execute

## Building for Release

### 1. Generate Signed APK/AAB

1. Build → Generate Signed Bundle/APK
2. Choose Android App Bundle (AAB) for Play Store
3. Create or select keystore
4. Select release build type

### 2. Configure ProGuard

Add to `proguard-rules.pro`:

```proguard
# Turbo
-keep class dev.hotwire.turbo.** { *; }

# Gson
-keep class com.joyfuljourney.User { *; }
-keep class com.joyfuljourney.LoginRequest { *; }
-keep class com.joyfuljourney.LoginResponse { *; }

# Retrofit
-keepattributes Signature
-keepattributes Exceptions
```

### 3. Test Release Build

```bash
./gradlew assembleRelease
adb install app/build/outputs/apk/release/app-release.apk
```

## Play Store Deployment

### Required Assets
- App icon (512x512)
- Feature graphic (1024x500)
- Screenshots for phones and tablets
- App description (short and full)
- Privacy policy URL
- Content rating questionnaire

### Pre-launch Checklist
- [ ] Remove debug logging
- [ ] Update BASE_URL to production
- [ ] Enable ProGuard/R8
- [ ] Test on multiple devices
- [ ] Review permissions
- [ ] Update version code/name

## Troubleshooting

### Common Issues

**WebView not loading:**
- Check internet permission
- Verify server URL
- Check network security config
- Review Logcat for errors

**Authentication failing:**
- Verify API endpoint URL
- Check CORS configuration in Rails
- Inspect network traffic with Charles/Proxyman
- Ensure token is being saved

**Camera not working:**
- Check camera permission in manifest
- Request runtime permission for Android 6+
- Test on real device (emulator limitations)

**Navigation issues:**
- Verify path configuration is loading
- Check TurboConfig setup
- Review fragment transactions

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Same as the main JoyfulJourney Rails application.