# Rails 8 & Hotwire Native Migration Plan

This document tracks the migration of Joyful Journey from a Progressive Web App (PWA) to native iOS/Android apps using Hotwire Native, while upgrading to Rails 8 with Solid Cache and Solid Queue.

## Migration Overview

**Start Date**: December 6, 2024  
**Current Rails Version**: 7.0.8  
**Target Rails Version**: 8.0.1  
**Current Stack**: PostgreSQL, BCrypt, Hotwire (Turbo + Stimulus), PWA  
**Target Stack**: Rails 8, Solid Cache, Solid Queue, Hotwire Native

## Todo List & Progress Tracker

### Phase 1: Rails 8 Upgrade & Solid Stack
- [ ] **1.1 Upgrade Rails to 8.0.1**
  - [ ] Update Gemfile
  - [ ] Run `rails app:update`
  - [ ] Fix deprecation warnings
  - [ ] Test application
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**: 

- [ ] **1.2 Implement Solid Cache**
  - [ ] Add solid_cache gem
  - [ ] Generate and run migrations
  - [ ] Configure cache store
  - [ ] Test caching
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

- [ ] **1.3 Implement Solid Queue**
  - [ ] Add solid_queue gem
  - [ ] Generate and run migrations
  - [ ] Configure queue adapter
  - [ ] Create sample background job
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

- [ ] **1.4 Configure Propshaft**
  - [ ] Verify Propshaft is default
  - [ ] Migrate any Sprockets-specific code
  - [ ] Test asset compilation
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 2: Prepare for Hotwire Native
- [ ] **2.1 Update Authentication for Mobile**
  - [ ] Create ApiToken model
  - [ ] Add token authentication
  - [ ] Update ApplicationController
  - [ ] Test dual authentication
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

- [ ] **2.2 Add Native Navigation Helpers**
  - [ ] Create HotwireNativeNavigation concern
  - [ ] Add navigation helper methods
  - [ ] Include in ApplicationController
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

- [ ] **2.3 Create Mobile-Specific Views**
  - [ ] Update application layout
  - [ ] Add native app detection
  - [ ] Conditional PWA features
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 3: Path Configuration
- [ ] **Create Path Configuration JSON**
  - [ ] Create iOS configuration
  - [ ] Create Android configuration
  - [ ] Host configuration files
  - [ ] Test configuration loading
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 4: Bridge Components
- [ ] **Implement Bridge Components**
  - [ ] Install @hotwired/hotwire-native-bridge
  - [ ] Create photo capture component
  - [ ] Create authentication component
  - [ ] Test bridge communication
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 5: iOS Native Shell
- [ ] **Build iOS Native Shell**
  - [ ] Create Xcode project
  - [ ] Implement SceneDelegate
  - [ ] Implement AppDelegate
  - [ ] Add bridge components
  - [ ] Test on simulator
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 6: Android Native Shell
- [ ] **Build Android Native Shell**
  - [ ] Create Android Studio project
  - [ ] Implement MainActivity
  - [ ] Implement Application class
  - [ ] Add bridge components
  - [ ] Test on emulator
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 7: Service Worker Migration
- [ ] **Service Worker Migration Strategy**
  - [ ] Conditional service worker registration
  - [ ] Add migration prompts
  - [ ] Test PWA compatibility
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 8: Testing
- [ ] **Add Tests for Mobile Views**
  - [ ] Create system tests for mobile
  - [ ] Test native navigation
  - [ ] Test bridge components
  - [ ] Run full test suite
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

### Phase 9: Deployment
- [ ] **Setup Progressive Rollout**
  - [ ] Configure feature flags
  - [ ] Setup monitoring
  - [ ] Create CI/CD pipelines
  - [ ] App store preparation
  - **Status**: Pending
  - **Issues**: None yet
  - **Notes**:

## Implementation Log

### December 6, 2024

#### Starting Migration
- Created this migration document
- Analyzed current application setup:
  - Rails 7.0.8 with PostgreSQL
  - Session-based authentication with bcrypt
  - Fully implemented PWA with service worker
  - Docker-based deployment
  - Hotwire (Turbo + Stimulus) already in place

#### Phase 1 Progress

**✅ Phase 1.1: Upgrade Rails to 8.0.1** - COMPLETED
- Successfully upgraded from Rails 7.0.8 to Rails 8.0.2
- Updated Gemfile and ran `bundle update rails`
- Ran `rails app:update` to update configuration files
- Updated Puma from 5.6 to 6.6.1
- Modified database.yml to support both Docker and local development
- Added environment variable support for DB_HOST and DB_PORT
- Fixed Docker configuration to expose PostgreSQL on port 5433

**✅ Phase 1.2: Implement Solid Cache** - COMPLETED
- Added solid_cache gem to Gemfile
- Generated Solid Cache installation files
- Created migration for solid_cache_entries table
- Configured production.rb to use solid_cache_store
- Successfully ran migration

**✅ Phase 1.3: Implement Solid Queue** - COMPLETED
- Added solid_queue gem to Gemfile
- Generated Solid Queue installation files
- Created comprehensive migration for all Solid Queue tables
- Configured production.rb to use solid_queue adapter
- Successfully ran migration with 11 tables created

**✅ Phase 1.4: Configure Propshaft** - COMPLETED
- Verified that sprockets-rails is still the default in Rails 8
- Application runs successfully with existing asset pipeline
- No changes needed for now (can migrate to Propshaft later if desired)

#### Issues Encountered & Resolved

**Issue #1**: Database connection error - "could not translate host name 'db'"
- **Resolution**: Modified database.yml to use environment variables for DB_HOST and DB_PORT
- Added fallback to localhost for local development

**Issue #2**: Port 5432 already in use
- **Resolution**: Changed Docker compose to expose PostgreSQL on port 5433
- Updated database.yml to use port 5433 as default

**Issue #3**: Test database not configured with correct host/port
- **Resolution**: Added host and port configuration to test database settings

#### Application Status
- Rails 8.0.2 running successfully on port 3001
- Solid Cache tables created and configured
- Solid Queue tables created and configured
- Database running in Docker on port 5433
- Ready to proceed with Phase 2 (Mobile Authentication)

---

## Phase 1: Rails 8 Upgrade & Solid Stack

### 1.1 Upgrade Rails to 8.0.1

#### Pre-upgrade Checklist
- [ ] Backup database
- [ ] Commit all current changes
- [ ] Review Rails 8 release notes
- [ ] Check gem compatibility

#### Implementation Steps

```ruby
# Gemfile changes
# FROM:
gem 'rails', '~> 7.0.8'

# TO:
gem 'rails', '~> 8.0.1'
```

#### Commands to Run
```bash
bundle update rails
rails app:update
rails db:migrate
```

#### Issues Encountered
- _To be documented during implementation_

#### Resolution
- _To be documented during implementation_

---

### 1.2 Implement Solid Cache

#### Implementation Steps

```ruby
# Gemfile
gem 'solid_cache'

# config/application.rb
config.cache_store = :solid_cache_store

# config/environments/production.rb
config.solid_cache.connects_to = { database: { writing: :cache } }
```

#### Database Configuration
```yaml
# config/database.yml addition
cache:
  <<: *default
  database: joyful_journey_cache
  migrations_paths: db/cache_migrate
```

#### Commands to Run
```bash
rails generate solid_cache:install
rails db:migrate
```

#### Testing
```ruby
# rails console
Rails.cache.write("test_key", "test_value")
Rails.cache.read("test_key") # Should return "test_value"
```

---

### 1.3 Implement Solid Queue

#### Implementation Steps

```ruby
# Gemfile
gem 'solid_queue'

# config/application.rb
config.active_job.queue_adapter = :solid_queue

# config/solid_queue.yml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      processes: 2
      polling_interval: 0.1
```

#### Database Setup
```bash
rails generate solid_queue:install
rails db:migrate
```

#### Sample Job for Testing
```ruby
# app/jobs/test_job.rb
class TestJob < ApplicationJob
  queue_as :default
  
  def perform(message)
    Rails.logger.info "Test job executed: #{message}"
  end
end
```

---

## Phase 2: Prepare for Hotwire Native

### 2.1 Update Authentication for Mobile

#### API Token Model
```ruby
# app/models/api_token.rb
class ApiToken < ApplicationRecord
  belongs_to :user
  
  before_create :generate_token
  
  scope :active, -> { where(revoked_at: nil) }
  
  def revoke!
    update!(revoked_at: Time.current)
  end
  
  def active?
    revoked_at.nil?
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.hex(32)
  end
end
```

#### Migration
```ruby
# db/migrate/xxx_create_api_tokens.rb
class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :name
      t.datetime :last_used_at
      t.datetime :revoked_at
      
      t.timestamps
    end
    
    add_index :api_tokens, :token, unique: true
  end
end
```

#### Updated ApplicationController
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include HotwireNativeNavigation
  
  helper_method :current_user, :logged_in?, :native_app?
  
  def current_user
    @current_user ||= authenticate_user
  end
  
  def logged_in?
    !!current_user
  end
  
  def native_app?
    request.user_agent&.include?('Hotwire Native')
  end
  
  private
  
  def authenticate_user
    if native_app?
      authenticate_with_token
    else
      User.find(session[:user_id]) if session[:user_id]
    end
  end
  
  def authenticate_with_token
    token = request.headers['Authorization']&.split(' ')&.last
    api_token = ApiToken.active.find_by(token: token)
    
    if api_token
      api_token.touch(:last_used_at)
      api_token.user
    end
  end
end
```

---

### 2.2 Native Navigation Helpers

```ruby
# app/controllers/concerns/hotwire_native_navigation.rb
module HotwireNativeNavigation
  extend ActiveSupport::Concern
  
  included do
    helper_method :hotwire_native_app?
  end
  
  def hotwire_native_app?
    request.user_agent.to_s.include?("Hotwire Native")
  end
  
  # Navigation methods for native apps
  def recede_or_redirect_to(url, **options)
    turbo_native_redirect_to(url, :recede, **options)
  end
  
  def resume_or_redirect_to(url, **options)
    turbo_native_redirect_to(url, :resume, **options)
  end
  
  def refresh_or_redirect_to(url, **options)
    turbo_native_redirect_to(url, :refresh, **options)
  end
  
  private
  
  def turbo_native_redirect_to(url, action, **options)
    if hotwire_native_app?
      render turbo_stream: turbo_stream.action(action, url)
    else
      redirect_to url, **options
    end
  end
end
```

---

## Phase 3: Path Configuration

### iOS Configuration
```json
// public/configurations/ios_v1.json
{
  "settings": {
    "feature_flags": [
      {
        "name": "native_photo_capture",
        "enabled": true
      },
      {
        "name": "push_notifications",
        "enabled": false
      },
      {
        "name": "biometric_auth",
        "enabled": false
      }
    ]
  },
  "rules": [
    {
      "patterns": [".*"],
      "properties": {
        "context": "default",
        "pull_to_refresh_enabled": true
      }
    },
    {
      "patterns": [
        "/posts/new$",
        "/users/new$",
        "/families/new$",
        "/login$"
      ],
      "properties": {
        "context": "modal",
        "pull_to_refresh_enabled": false,
        "modal_style": "medium"
      }
    },
    {
      "patterns": [
        "/posts/\\d+/edit$",
        "/users/\\d+/edit$"
      ],
      "properties": {
        "context": "modal",
        "modal_style": "full"
      }
    }
  ]
}
```

### Android Configuration
```json
// public/configurations/android_v1.json
{
  "settings": {
    "feature_flags": [
      {
        "name": "native_photo_capture",
        "enabled": true
      },
      {
        "name": "push_notifications",
        "enabled": false
      }
    ]
  },
  "rules": [
    {
      "patterns": [".*"],
      "properties": {
        "context": "default",
        "uri": "hotwire://fragment/web",
        "pull_to_refresh_enabled": true
      }
    },
    {
      "patterns": [
        "/posts/new$",
        "/users/new$",
        "/families/new$",
        "/login$"
      ],
      "properties": {
        "context": "modal",
        "uri": "hotwire://fragment/web/modal/sheet",
        "pull_to_refresh_enabled": false
      }
    }
  ]
}
```

---

## Phase 4: Bridge Components

### JavaScript Bridge Components

```javascript
// app/javascript/bridge/index.js
import PhotoComponent from "./photo_component"
import AuthComponent from "./auth_component"

export { PhotoComponent, AuthComponent }
```

```javascript
// app/javascript/bridge/photo_component.js
import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "photo"
  
  connect() {
    super.connect()
    
    const element = this.bridgeElement
    const fieldName = element.bridgeAttribute("field-name")
    const multiple = element.bridgeAttribute("multiple") === "true"
    
    this.send("capturePhoto", { fieldName, multiple }, (result) => {
      if (result.success) {
        this.displayPhoto(result.photoUrl)
        this.updateHiddenField(result.photoData)
      }
    })
  }
  
  displayPhoto(url) {
    const preview = this.element.querySelector('[data-photo-preview]')
    if (preview) {
      preview.src = url
      preview.style.display = 'block'
    }
  }
  
  updateHiddenField(data) {
    const field = this.element.querySelector('input[type="hidden"]')
    if (field) {
      field.value = data
    }
  }
}
```

```javascript
// app/javascript/bridge/auth_component.js
import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "auth"
  
  connect() {
    super.connect()
    
    const element = this.bridgeElement
    const authType = element.bridgeAttribute("auth-type") // "biometric" or "pin"
    
    this.send("authenticate", { authType }, (result) => {
      if (result.success) {
        this.handleAuthSuccess(result)
      } else {
        this.handleAuthFailure(result)
      }
    })
  }
  
  handleAuthSuccess(result) {
    // Store token or proceed with action
    const form = this.element.closest('form')
    if (form) {
      const tokenField = document.createElement('input')
      tokenField.type = 'hidden'
      tokenField.name = 'auth_token'
      tokenField.value = result.token
      form.appendChild(tokenField)
      form.submit()
    }
  }
  
  handleAuthFailure(result) {
    const errorElement = this.element.querySelector('[data-auth-error]')
    if (errorElement) {
      errorElement.textContent = result.error
      errorElement.style.display = 'block'
    }
  }
}
```

---

## Issues & Resolutions Log

### Issue #1: [Date] - Issue Title
**Description**: 
**Error Message**: 
**Resolution**: 
**Time Spent**: 

---

## Testing Checklist

### Unit Tests
- [ ] Model tests pass
- [ ] Controller tests pass
- [ ] Job tests pass
- [ ] Helper tests pass

### System Tests
- [ ] Web navigation works
- [ ] Mobile navigation works
- [ ] Authentication works for both web and mobile
- [ ] Bridge components communicate properly

### Manual Testing
- [ ] PWA still functions correctly
- [ ] iOS app loads and navigates
- [ ] Android app loads and navigates
- [ ] Photo capture works on mobile
- [ ] Forms submit correctly
- [ ] Cache is working (Solid Cache)
- [ ] Background jobs process (Solid Queue)

---

## Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] Database migrations ready
- [ ] Environment variables configured
- [ ] SSL certificates valid
- [ ] Backup created

### Mobile App Submission
- [ ] iOS app tested on physical device
- [ ] Android app tested on physical device
- [ ] App store descriptions written
- [ ] Screenshots prepared
- [ ] Privacy policy updated
- [ ] Terms of service updated

### Post-deployment
- [ ] Monitor error logs
- [ ] Check performance metrics
- [ ] Verify background jobs running
- [ ] Test critical user paths
- [ ] Monitor cache hit rates

---

## Performance Metrics

### Before Migration
- Page Load Time: _TBD_
- Time to Interactive: _TBD_
- Memory Usage: _TBD_
- Cache Hit Rate: _TBD_

### After Migration
- Page Load Time: _TBD_
- Time to Interactive: _TBD_
- Memory Usage: _TBD_
- Cache Hit Rate: _TBD_

---

## Resources & References

- [Rails 8 Release Notes](https://rubyonrails.org/2024/11/7/rails-8-0-has-been-released)
- [Solid Cache Documentation](https://github.com/rails/solid_cache)
- [Solid Queue Documentation](https://github.com/rails/solid_queue)
- [Hotwire Native Documentation](https://native.hotwired.dev)
- [Turbo Rails Documentation](https://github.com/hotwired/turbo-rails)

---

## Notes

- PWA will continue to function during migration
- Native apps will be released gradually
- Feature flags will control rollout
- Monitoring is critical during transition

---

_This document is actively maintained during the migration process. Last updated: December 6, 2024_