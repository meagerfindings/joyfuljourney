class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  validates :activity_type, presence: true
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_family, ->(family) { joins(:user).where(users: { family: family }) }
  scope :by_type, ->(type) { where(activity_type: type) }
  scope :for_trackable, ->(trackable) { where(trackable: trackable) }

  # Activity types
  TYPES = {
    post_created: 'post_created',
    post_updated: 'post_updated',
    post_reacted: 'post_reacted',
    milestone_created: 'milestone_created',
    milestone_updated: 'milestone_updated',
    user_tagged: 'user_tagged',
    family_joined: 'family_joined',
    user_created: 'user_created'
  }.freeze

  def data_hash
    return {} unless data.present?
    
    JSON.parse(data)
  rescue JSON::ParserError
    {}
  end

  def data_hash=(hash)
    self.data = hash.to_json
  end

  def description
    case activity_type
    when TYPES[:post_created]
      "created a new post"
    when TYPES[:post_updated]
      "updated a post"
    when TYPES[:post_reacted]
      reaction_type = data_hash['reaction_type'] || 'reacted'
      "#{reaction_type} a post"
    when TYPES[:milestone_created]
      "reached a new milestone"
    when TYPES[:milestone_updated]
      "updated a milestone"
    when TYPES[:user_tagged]
      "tagged someone"
    when TYPES[:family_joined]
      "joined the family"
    when TYPES[:user_created]
      "joined Joyful Journey"
    else
      "performed an activity"
    end
  end

  def icon_class
    case activity_type
    when TYPES[:post_created], TYPES[:post_updated]
      'bi-file-post'
    when TYPES[:post_reacted]
      'bi-heart'
    when TYPES[:milestone_created], TYPES[:milestone_updated]
      'bi-trophy'
    when TYPES[:user_tagged]
      'bi-at'
    when TYPES[:family_joined]
      'bi-people'
    when TYPES[:user_created]
      'bi-person-plus'
    else
      'bi-activity'
    end
  end

  def color_class
    case activity_type
    when TYPES[:post_reacted]
      'text-danger'
    when TYPES[:milestone_created], TYPES[:milestone_updated]
      'text-warning'
    when TYPES[:family_joined], TYPES[:user_created]
      'text-success'
    when TYPES[:user_tagged]
      'text-info'
    else
      'text-primary'
    end
  end

  def path
    case activity_type
    when TYPES[:post_created], TYPES[:post_updated], TYPES[:post_reacted]
      "/posts/#{trackable.id}" if trackable.is_a?(Post)
    when TYPES[:milestone_created], TYPES[:milestone_updated]
      "/milestones/#{trackable.id}" if trackable.is_a?(Milestone)
    when TYPES[:user_tagged]
      case trackable
      when Post
        "/posts/#{trackable.id}"
      when Milestone
        "/milestones/#{trackable.id}"
      end
    when TYPES[:family_joined]
      "/families/#{trackable.id}" if trackable.is_a?(Family)
    when TYPES[:user_created]
      "/users/#{trackable.id}" if trackable.is_a?(User)
    else
      '/'
    end
  end

  def time_ago
    if occurred_at > 24.hours.ago
      "#{time_ago_in_words(occurred_at)} ago"
    elsif occurred_at > 1.week.ago
      occurred_at.strftime("%A at %l:%M %p")
    else
      occurred_at.strftime("%B %d, %Y")
    end
  end

  private

  def time_ago_in_words(time)
    distance = Time.current - time
    
    case distance
    when 0..59
      "#{distance.to_i} seconds"
    when 60..3599
      "#{(distance / 60).to_i} minutes"
    when 3600..86399
      "#{(distance / 3600).to_i} hours"
    else
      "#{(distance / 86400).to_i} days"
    end
  end
end
