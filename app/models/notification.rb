class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  validates :notification_type, presence: true
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(recipient: user) }
  scope :for_family, ->(family) { where(recipient: family) }
  scope :by_type, ->(type) { where(notification_type: type) }

  # Notification types
  TYPES = {
    post_created: 'post_created',
    post_updated: 'post_updated',
    post_reaction: 'post_reaction',
    milestone_created: 'milestone_created',
    milestone_updated: 'milestone_updated',
    user_tagged: 'user_tagged',
    family_joined: 'family_joined',
    birthday_reminder: 'birthday_reminder'
  }.freeze

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def mark_as_unread!
    update!(read_at: nil) if read?
  end

  def data_hash
    return {} unless data.present?
    
    JSON.parse(data)
  rescue JSON::ParserError
    {}
  end

  def data_hash=(hash)
    self.data = hash.to_json
  end

  def email_sent?
    email_sent_at.present?
  end

  def mark_email_as_sent!
    update!(email_sent_at: Time.current) unless email_sent?
  end

  def icon_class
    case notification_type
    when TYPES[:post_created]
      'bi-file-post'
    when TYPES[:post_updated]
      'bi-file-post'
    when TYPES[:post_reaction]
      'bi-heart'
    when TYPES[:milestone_created]
      'bi-trophy'
    when TYPES[:milestone_updated]
      'bi-trophy'
    when TYPES[:user_tagged]
      'bi-at'
    when TYPES[:family_joined]
      'bi-people'
    when TYPES[:birthday_reminder]
      'bi-cake'
    else
      'bi-bell'
    end
  end

  def color_class
    case notification_type
    when TYPES[:post_reaction]
      'text-danger'
    when TYPES[:milestone_created], TYPES[:milestone_updated]
      'text-warning'
    when TYPES[:family_joined]
      'text-success'
    when TYPES[:birthday_reminder]
      'text-info'
    else
      'text-primary'
    end
  end

  def path
    case notification_type
    when TYPES[:post_created], TYPES[:post_updated], TYPES[:post_reaction]
      "/posts/#{notifiable.id}" if notifiable.is_a?(Post)
    when TYPES[:milestone_created], TYPES[:milestone_updated]
      "/milestones/#{notifiable.id}" if notifiable.is_a?(Milestone)
    when TYPES[:user_tagged]
      case notifiable
      when Post
        "/posts/#{notifiable.id}"
      when Milestone
        "/milestones/#{notifiable.id}"
      end
    when TYPES[:family_joined]
      "/families/#{notifiable.id}" if notifiable.is_a?(Family)
    when TYPES[:birthday_reminder]
      "/users/#{notifiable.id}" if notifiable.is_a?(User)
    else
      '/'
    end
  end
end
