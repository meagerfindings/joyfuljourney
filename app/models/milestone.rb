class Milestone < ApplicationRecord
  validates :title, presence: true
  validates :milestone_date, presence: true
  validates :milestone_type, presence: true
  validates :milestoneable_type, presence: true
  validates :milestoneable_id, presence: true
  validates :created_by_user_id, presence: true

  belongs_to :milestoneable, polymorphic: true
  belongs_to :created_by_user, class_name: 'User', foreign_key: 'created_by_user_id'

  MILESTONE_TYPES = [
    'birth',
    'birthday',
    'graduation',
    'wedding',
    'anniversary',
    'new_job',
    'retirement',
    'moving',
    'achievement',
    'milestone_birthday',
    'first_steps',
    'first_words',
    'first_day_school',
    'driving_license',
    'other'
  ].freeze

  validates :milestone_type, inclusion: { in: MILESTONE_TYPES }

  scope :for_user, ->(user) { where(milestoneable: user) }
  scope :for_post, ->(post) { where(milestoneable: post) }
  scope :for_family, ->(family) { where(milestoneable: family) }
  scope :public_milestones, -> { where(is_private: false) }
  scope :private_milestones, -> { where(is_private: true) }
  scope :by_date, -> { order(:milestone_date) }
  scope :recent, -> { order(created_at: :desc) }

  def milestone_type_display
    milestone_type.humanize
  end

  def visible_to?(user)
    return true unless is_private
    
    case milestoneable_type
    when 'User'
      user == milestoneable || user == created_by_user || (milestoneable.family && user.family == milestoneable.family)
    when 'Family'
      user.family == milestoneable || user == created_by_user
    when 'Post'
      user == milestoneable.user || user == created_by_user || (!milestoneable.private && user.family == milestoneable.user.family)
    else
      user == created_by_user
    end
  end
end