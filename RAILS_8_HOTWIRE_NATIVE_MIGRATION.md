# Rails 8 & Hotwire Native Migration Plan

This document tracks the migration from Rails 7.0.8 PWA to Rails 8 with Hotwire Native for iOS/Android mobile apps.

## Migration Status

**Branch**: `feature/rails-8-hotwire-native` (created from main)
**Started**: 2025-08-06
**Current Phase**: Phase 1 - Rails 8 Upgrade

## Phase 1: Upgrade to Rails 8 and Solid Stack ✅

### 1.1 Rails Version Upgrade ✅
- [x] Update Gemfile to Rails 8.0.0
- [x] Update Puma to 6.0
- [x] Run bundle update
- [x] Rails successfully upgraded to 8.0.2

### 1.2 Solid Cache Implementation ✅
- [x] Add solid_cache gem
- [x] Generate Solid Cache configuration
- [x] Create migration for solid_cache_entries table
- [x] Run migration successfully
- [x] Configuration auto-added to production.rb

### 1.3 Solid Queue Implementation ✅
- [x] Add solid_queue gem
- [x] Generate Solid Queue configuration
- [x] Create migration for 11 Solid Queue tables
- [x] Run migration successfully
- [x] Configuration auto-added to production.rb
- [x] Created bin/jobs executable

### 1.4 Database Configuration Updates ✅
- [x] Modified database.yml for flexible Docker/local development
- [x] Added environment variable support for DB_HOST and DB_PORT
- [x] Default to localhost:5433 for local development
- [x] Updated test database configuration

## Phase 2: Update Authentication for Mobile Apps ✅

### 2.1 Add Token Authentication ✅
- [x] Add authentication_token to User model
- [x] Create token generation on login
- [x] Add API authentication concern
- [x] Update sessions controller for token response

### 2.2 Add Native Navigation Helpers ✅
- [x] Add turbo_native_app? helper
- [x] Add turbo_native_ios? and turbo_native_android? helpers
- [x] Update current_user to support token authentication
- [x] Handle native app authentication flow

### 2.3 Create Mobile-Specific Views ✅
- [x] Create app/views/layouts/application.html+turbo_native.erb
- [x] Add safe area insets for iOS
- [x] Remove navbar for native apps
- [x] Add bridge component placeholders

### 2.4 API Controllers and Routes ✅
- [x] Create Api::V1::BaseController with token auth
- [x] Create Api::V1::SessionsController for login/logout
- [x] Add API routes for mobile authentication
- [x] Create TurboController for path configurations
- [x] Add turbo_native.js for bridge components

## Phase 3: Create Path Configuration

### 3.1 Path Configuration JSON
- [ ] Create config/turbo/ios_path_configuration.json
- [ ] Create config/turbo/android_path_configuration.json
- [ ] Define modal presentation rules
- [ ] Set up tab navigation structure

### 3.2 Path Configuration Controller
- [ ] Create PathConfigurationsController
- [ ] Add routes for path configuration endpoints
- [ ] Add versioning support

## Phase 4: Implement Bridge Components

### 4.1 Core Bridge Components
- [ ] Create app/javascript/bridges/menu.js
- [ ] Create app/javascript/bridges/form.js
- [ ] Create app/javascript/bridges/flash.js
- [ ] Register components in application.js

### 4.2 Native Feature Bridges
- [ ] Camera/photo picker bridge
- [ ] Share sheet bridge
- [ ] Native navigation bridge
- [ ] Push notification bridge setup

## Phase 5: Build iOS Native Shell

### 5.1 iOS Project Setup
- [ ] Create iOS Xcode project
- [ ] Add Turbo iOS framework
- [ ] Configure app identifier and signing
- [ ] Set up development/production server URLs

### 5.2 iOS Implementation
- [ ] Implement Session and SceneDelegate
- [ ] Add path configuration loading
- [ ] Implement bridge component handlers
- [ ] Add native tab bar

### 5.3 iOS Testing
- [ ] Test authentication flow
- [ ] Verify navigation patterns
- [ ] Test bridge components
- [ ] Submit TestFlight build

## Phase 6: Build Android Native Shell

### 6.1 Android Project Setup
- [ ] Create Android Studio project
- [ ] Add Turbo Android library
- [ ] Configure app manifest
- [ ] Set up build variants

### 6.2 Android Implementation
- [ ] Implement MainActivity
- [ ] Add path configuration loading
- [ ] Implement bridge component handlers
- [ ] Add bottom navigation

### 6.3 Android Testing
- [ ] Test authentication flow
- [ ] Verify navigation patterns
- [ ] Test bridge components
- [ ] Create internal test release

## Phase 7: Service Worker Migration

### 7.1 PWA to Native Migration Strategy
- [ ] Identify offline features to migrate
- [ ] Plan native caching strategy
- [ ] Update manifest.json for web-only
- [ ] Create migration guide for users

### 7.2 Implement Native Offline Support
- [ ] Add Turbo offline support
- [ ] Cache critical pages natively
- [ ] Handle offline form submissions
- [ ] Add offline indicators

## Phase 8: Testing & Quality Assurance

### 8.1 Add Mobile-Specific Tests
- [ ] Add request specs for API endpoints
- [ ] Test turbo_native_app? detection
- [ ] Test authentication token flow
- [ ] Add system tests for mobile views

### 8.2 Cross-Platform Testing
- [ ] Test on iOS devices
- [ ] Test on Android devices
- [ ] Verify web app still works
- [ ] Performance testing

## Phase 9: Deployment & Rollout

### 9.1 Infrastructure Updates
- [ ] Update Docker configs for Rails 8
- [ ] Configure Solid Queue workers
- [ ] Set up monitoring for mobile apps
- [ ] Configure push notification services

### 9.2 Progressive Rollout
- [ ] Deploy to staging
- [ ] Beta testing with select users
- [ ] App Store submission
- [ ] Google Play submission
- [ ] Production deployment

## Issues Encountered & Resolutions

### Issue 1: Database Connection Error
**Problem**: Rails commands failing with "could not translate host name 'db'"
**Resolution**: Updated database.yml to use environment variables DB_HOST and DB_PORT with fallback to localhost:5433

### Issue 2: Wrong Branch
**Problem**: Initially started work on feature/progressive-web-app branch
**Resolution**: Created new feature/rails-8-hotwire-native branch from main as requested

## Configuration Files Created

1. **config/cache.yml** - Solid Cache configuration
2. **config/queue.yml** - Solid Queue configuration
3. **config/recurring.yml** - Recurring jobs configuration
4. **db/cache_schema.rb** - Cache table schema
5. **db/queue_schema.rb** - Queue tables schema
6. **bin/jobs** - Solid Queue executable

## Database Migrations Created

1. **20250806143223_create_solid_cache_entries.rb** - Solid Cache table
2. **20250806143237_create_solid_queue_tables.rb** - 11 Solid Queue tables with foreign keys

## Phase 2 Completed Files

### New Files Created:
1. **app/controllers/concerns/api_authenticatable.rb** - Token authentication concern
2. **app/controllers/api/v1/base_controller.rb** - Base API controller
3. **app/controllers/api/v1/sessions_controller.rb** - API login/logout
4. **app/controllers/turbo_controller.rb** - Path configuration endpoints
5. **app/views/layouts/application.html+turbo_native.erb** - Native app layout
6. **app/javascript/turbo_native.js** - Bridge component JavaScript

### Modified Files:
1. **app/models/user.rb** - Added token generation methods
2. **app/controllers/application_controller.rb** - Added native helpers and token auth
3. **app/controllers/users_controller.rb** - JSON response for native login
4. **config/routes.rb** - Added API and turbo routes
5. **db/schema.rb** - Added authentication_token to users

### Database Changes:
- Migration: 20250806150036_add_authentication_token_to_users.rb
- Added authentication_token field with unique index to users table

## Next Steps

1. Phase 3: Create detailed path configurations for iOS and Android
2. Phase 4: Implement bridge components for native features
3. Phase 5: Create iOS native shell application
4. Phase 6: Create Android native shell application

## Notes

- Rails 8 upgrade successful (7.0.8 → 8.0.2)
- Solid Cache and Solid Queue fully configured
- Database connectivity issues resolved
- Ready to proceed with mobile authentication implementation