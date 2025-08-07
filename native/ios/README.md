# JoyfulJourney iOS App

Native iOS shell for the JoyfulJourney Rails application using Turbo Native.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- CocoaPods or Swift Package Manager

## Setup

### 1. Create Xcode Project

1. Open Xcode and create a new iOS App
2. Product Name: `JoyfulJourney`
3. Organization Identifier: `com.yourcompany`
4. Interface: `UIKit`
5. Language: `Swift`

### 2. Add Turbo iOS Framework

#### Using Swift Package Manager (Recommended)

1. In Xcode, go to File → Add Package Dependencies
2. Enter: `https://github.com/hotwired/turbo-ios`
3. Version: `Up to Next Major Version` → `7.1.0`
4. Click "Add Package"

#### Using CocoaPods

Add to your `Podfile`:

```ruby
pod 'Turbo', '~> 7.1.0'
```

Then run:
```bash
pod install
```

### 3. Add Project Files

Copy all Swift files from this directory to your Xcode project:

- `AppDelegate.swift`
- `MainTabBarController.swift`
- `AuthenticationManager.swift`
- `KeychainHelper.swift`
- Bridge Components:
  - `BridgeComponents/MenuBridge.swift`
  - `BridgeComponents/CameraBridge.swift`

### 4. Configure Info.plist

Add the following to your `Info.plist`:

```xml
<!-- Camera Usage -->
<key>NSCameraUsageDescription</key>
<string>JoyfulJourney needs access to your camera to capture photos for posts.</string>

<!-- Photo Library Usage -->
<key>NSPhotoLibraryUsageDescription</key>
<string>JoyfulJourney needs access to your photos to add them to posts.</string>

<!-- Allow HTTP for local development -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>

<!-- Support all orientations -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

### 5. Configure Server URL

Update the server URL in `AppDelegate.swift`:

```swift
struct Server {
    #if DEBUG
    static let baseURL = "http://localhost:3000"  // Your local Rails server
    #else
    static let baseURL = "https://joyfuljourney.com"  // Your production server
    #endif
}
```

## Features

### Authentication
- Token-based authentication with Keychain storage
- Automatic token injection into web requests
- Login/logout flow with modal presentation

### Navigation
- Tab bar navigation with 5 main sections
- Modal presentation for forms
- Path configuration loaded from server
- Pull-to-refresh support

### Bridge Components

#### Menu Bridge
- Native menu with dynamic items
- Role-based menu options
- Logout functionality

#### Camera Bridge
- Native camera capture
- Photo library selection
- Multiple photo support
- Base64 encoding for web upload

#### Flash Bridge (To be implemented)
- Native toast notifications
- Alert dialogs

#### Share Bridge (To be implemented)
- Native share sheet
- Social media integration

#### Form Bridge (To be implemented)
- Native keyboard handling
- Form validation

## Development

### Running Locally

1. Start your Rails server:
```bash
rails server
```

2. Build and run the iOS app in Xcode (Cmd+R)

3. The app will connect to `http://localhost:3000` in debug mode

### Testing Authentication

1. Create a user in your Rails app
2. Launch the iOS app
3. Login with the user credentials
4. The token will be stored in Keychain

### Debugging

Enable Turbo debugging in `AppDelegate.swift`:

```swift
#if DEBUG
Turbo.config.debugLoggingEnabled = true
#endif
```

Check the Xcode console for:
- Navigation events
- Bridge component messages
- Network requests
- JavaScript errors

## Deployment

### App Store Preparation

1. Update bundle identifier
2. Configure signing certificates
3. Update server URL for production
4. Add app icons and launch screen
5. Test on real devices

### Required App Store Assets

- App Icon (1024x1024)
- Screenshots for all device sizes
- App description
- Privacy policy URL
- Support URL

## Architecture

### Session Management
- Single `Session` instance manages all web views
- Shared across all tabs
- Handles navigation and errors

### View Controllers
- `MainTabBarController`: Root tab bar controller
- `VisitableViewController`: Turbo-powered web views
- Modal presentation for forms

### Data Flow
1. User navigates → Path configuration determines presentation
2. Web view loads → Bridge components register
3. JavaScript events → Native handlers respond
4. Native actions → JavaScript callbacks execute

## Troubleshooting

### Common Issues

**Cannot connect to local server:**
- Ensure Rails server is running on port 3000
- Check that your Mac and iOS device/simulator are on the same network
- Verify NSAppTransportSecurity settings

**Authentication not persisting:**
- Check Keychain entitlements
- Verify token is being sent in headers
- Check Rails CORS configuration

**Bridge components not working:**
- Verify JavaScript files are loaded
- Check message handler registration
- Review Xcode console for errors

**Camera/Photos not working:**
- Check Info.plist permissions
- Test on real device (simulator limitations)
- Verify user has granted permissions

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Same as the main JoyfulJourney Rails application.