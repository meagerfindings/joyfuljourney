# Progressive Rollout Plan

This document outlines the strategy for progressively rolling out the native mobile apps while maintaining stability.

## Rollout Phases

### Phase 1: Internal Testing (Week 1-2)

#### iOS TestFlight Beta
```bash
# Build for TestFlight
xcodebuild -project JoyfulJourney.xcodeproj \
  -scheme JoyfulJourney \
  -configuration Release \
  -archivePath ./build/JoyfulJourney.xcarchive \
  archive

# Upload to App Store Connect
xcrun altool --upload-app \
  -f ./build/JoyfulJourney.ipa \
  -u developer@example.com \
  -p app-specific-password
```

#### Android Internal Testing
```bash
# Build release AAB
./gradlew bundleRelease

# Upload to Play Console Internal Testing track
# Use Play Console API or manual upload
```

#### Testing Checklist
- [ ] Authentication flow (login/logout)
- [ ] Token persistence across app restarts
- [ ] Navigation between all main sections
- [ ] Form submissions
- [ ] Photo upload functionality
- [ ] Offline behavior
- [ ] Push notifications (if implemented)
- [ ] Deep linking
- [ ] App updates

### Phase 2: Beta Testing (Week 3-4)

#### User Selection Criteria
```ruby
# app/models/user.rb
class User < ApplicationRecord
  scope :beta_testers, -> {
    where(role: ['admin', 'manager'])
    .or(where(created_at: ..6.months.ago))
    .where(claimed: true)
  }
  
  def eligible_for_beta?
    admin? || manager? || (created_at < 6.months.ago && posts.count > 10)
  end
end
```

#### Beta Invitation System
```ruby
# app/mailers/beta_invitation_mailer.rb
class BetaInvitationMailer < ApplicationMailer
  def ios_beta_invite(user)
    @user = user
    @testflight_link = "https://testflight.apple.com/join/XXXXXX"
    
    mail(
      to: user.email,
      subject: "You're invited to test JoyfulJourney for iOS!"
    )
  end
  
  def android_beta_invite(user)
    @user = user
    @play_store_link = "https://play.google.com/apps/testing/com.joyfuljourney"
    
    mail(
      to: user.email,
      subject: "You're invited to test JoyfulJourney for Android!"
    )
  end
end
```

#### In-App Beta Promotion
```erb
<!-- app/views/shared/_beta_banner.html.erb -->
<% if current_user&.eligible_for_beta? && !turbo_native_app? %>
  <div class="beta-banner" data-controller="beta-banner">
    <div class="container">
      <h3>🎉 Try our new mobile apps!</h3>
      <p>You're invited to be among the first to experience JoyfulJourney natively.</p>
      
      <div class="app-buttons">
        <a href="<%= ios_beta_url %>" class="btn btn-ios" data-action="click->beta-banner#trackIOS">
          <i class="bi bi-apple"></i> Join iOS Beta
        </a>
        <a href="<%= android_beta_url %>" class="btn btn-android" data-action="click->beta-banner#trackAndroid">
          <i class="bi bi-android"></i> Join Android Beta
        </a>
      </div>
      
      <button class="close" data-action="click->beta-banner#dismiss">×</button>
    </div>
  </div>
<% end %>
```

### Phase 3: Staged Rollout (Week 5-8)

#### Feature Flags Implementation
```ruby
# app/models/feature_flag.rb
class FeatureFlag < ApplicationRecord
  def self.enabled?(flag_name, user = nil)
    flag = find_by(name: flag_name)
    return false unless flag&.enabled?
    
    case flag.rollout_percentage
    when 0
      false
    when 100
      true
    else
      # Consistent user bucketing
      user_bucket = user ? user.id % 100 : rand(100)
      user_bucket < flag.rollout_percentage
    end
  end
end

# Usage in controllers
class ApplicationController < ActionController::Base
  def native_app_available?
    FeatureFlag.enabled?('native_apps', current_user)
  end
  helper_method :native_app_available?
end
```

#### Gradual Rollout Schedule
| Week | iOS % | Android % | Target Users |
|------|-------|-----------|--------------|
| 5    | 10%   | 10%       | Power users  |
| 6    | 25%   | 25%       | Active users |
| 7    | 50%   | 50%       | Regular users|
| 8    | 100%  | 100%      | All users    |

### Phase 4: Full Release (Week 9+)

#### App Store Optimization
```yaml
# iOS App Store Metadata
app_store:
  name: "JoyfulJourney - Family Memories"
  subtitle: "Capture and share your family's story"
  keywords:
    - family
    - memories
    - photos
    - journal
    - sharing
  description: |
    JoyfulJourney helps families capture, organize, and share their 
    precious memories in a private, secure environment.
    
    Features:
    • Create posts with photos and stories
    • Build your family tree
    • Track milestones and achievements
    • Share privately with family members
    • Offline access to your memories
  
  screenshots:
    - home_screen.png
    - create_post.png
    - family_view.png
    - timeline.png
    - profile.png

# Android Play Store Metadata  
play_store:
  title: "JoyfulJourney: Family Memory Journal"
  short_description: "Capture and share family memories privately"
  full_description: |
    Similar to iOS description...
```

## Monitoring & Analytics

### Key Metrics Dashboard
```ruby
# app/services/rollout_metrics.rb
class RolloutMetrics
  def self.dashboard_data
    {
      adoption: {
        ios_downloads: AppStoreMetrics.downloads(:ios),
        android_downloads: PlayStoreMetrics.downloads(:android),
        daily_active_native: User.joins(:sessions)
          .where(sessions: { platform: ['ios', 'android'] })
          .where('sessions.created_at > ?', 1.day.ago)
          .distinct.count
      },
      performance: {
        avg_load_time: {
          web: PageLoadMetric.web.average(:duration),
          ios: PageLoadMetric.ios.average(:duration),
          android: PageLoadMetric.android.average(:duration)
        },
        crash_rate: {
          ios: CrashMetric.ios.rate,
          android: CrashMetric.android.rate
        }
      },
      engagement: {
        posts_created: {
          web: Post.web.count,
          native: Post.native.count
        },
        session_duration: {
          web: Session.web.average(:duration),
          native: Session.native.average(:duration)
        }
      }
    }
  end
end
```

### Error Tracking
```ruby
# config/initializers/error_tracking.rb
if Rails.env.production?
  # Sentry or similar
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger]
    
    config.before_send = lambda do |event, hint|
      # Add platform context
      if event.request
        user_agent = event.request.headers['User-Agent']
        event.tags[:platform] = case user_agent
        when /Turbo Native iOS/ then 'ios_native'
        when /Turbo Native Android/ then 'android_native'
        else 'web'
        end
      end
      event
    end
  end
end
```

## Rollback Procedures

### Emergency Rollback Triggers
1. Crash rate > 1%
2. Authentication failures > 5%
3. Data loss reports
4. Security vulnerabilities

### Rollback Steps
```ruby
# 1. Disable native app promotion
FeatureFlag.find_by(name: 'native_apps').update!(enabled: false)

# 2. Show maintenance message in apps
class Api::V1::StatusController < ApplicationController
  def index
    render json: {
      status: 'maintenance',
      message: 'Please use the web version while we fix issues',
      web_url: 'https://joyfuljourney.com'
    }
  end
end

# 3. Notify users
User.with_native_app.find_each do |user|
  MaintenanceMailer.native_app_issue(user).deliver_later
end
```

## Success Criteria

### Technical Metrics
- [ ] < 0.1% crash rate
- [ ] < 2s average load time
- [ ] > 99.9% uptime
- [ ] < 100ms API response time

### Business Metrics
- [ ] > 30% native app adoption in 3 months
- [ ] > 4.5 star rating
- [ ] < 5% uninstall rate
- [ ] > 50% weekly active users

### User Feedback
- [ ] NPS score > 50
- [ ] < 10 critical bugs reported
- [ ] Positive app store reviews
- [ ] Feature requests (not complaints)

## Communication Plan

### User Communications
1. **Email Campaigns**
   - Beta invitation emails
   - Launch announcement
   - Feature updates
   - Tips and tricks

2. **In-App Messages**
   - Update notifications
   - New feature highlights
   - Migration prompts
   - Success celebrations

3. **Social Media**
   - Launch announcement
   - User testimonials
   - Feature spotlights
   - Support responses

### Internal Communications
1. **Daily Standups** during rollout
2. **Weekly metrics review**
3. **Incident response channel**
4. **Stakeholder updates**

## Post-Launch Optimization

### A/B Testing Framework
```ruby
# app/services/ab_test_service.rb
class ABTestService
  TESTS = {
    onboarding_flow: {
      variants: ['original', 'simplified', 'guided'],
      metric: 'completion_rate'
    },
    navigation_style: {
      variants: ['tabs', 'drawer', 'hybrid'],
      metric: 'engagement_rate'
    }
  }
  
  def self.variant_for(test_name, user)
    test = TESTS[test_name]
    return test[:variants].first unless test
    
    # Consistent assignment based on user ID
    index = user.id % test[:variants].length
    test[:variants][index]
  end
end
```

### Continuous Improvement
1. Weekly user feedback review
2. Monthly feature prioritization
3. Quarterly major updates
4. Annual platform review

## Conclusion

The progressive rollout ensures a smooth transition from PWA to native apps while maintaining service quality and user satisfaction. By monitoring key metrics and having clear rollback procedures, we can confidently deploy the native apps while minimizing risk.