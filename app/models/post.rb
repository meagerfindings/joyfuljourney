class Post < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
  validate :validate_photos
  validate :validate_videos
  validate :validate_audio_recordings

  belongs_to :user
  has_and_belongs_to_many :tagged_users, class_name: 'User'
  has_many :milestones, as: :milestoneable, dependent: :destroy
  has_many_attached :photos
  has_many_attached :videos
  has_many_attached :audio_recordings

  scope :visible_to_family, ->(family) { 
    joins(:user).where(users: { family: family }).where(private: false)
  }

  scope :private_posts, -> { where(private: true) }
  scope :public_posts, -> { where(private: false) }

  private

  def validate_photos
    return unless photos.attached?

    photos.each do |photo|
      unless photo.blob.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
        errors.add(:photos, 'must be JPEG, JPG, PNG, or GIF')
      end

      if photo.blob.byte_size > 10.megabytes
        errors.add(:photos, 'size must be less than 10MB')
      end
    end
  end

  def validate_videos
    return unless videos.attached?

    videos.each do |video|
      unless video.blob.content_type.in?(%w[video/mp4 video/webm video/ogg video/quicktime])
        errors.add(:videos, 'must be MP4, WebM, OGG, or MOV')
      end

      if video.blob.byte_size > 100.megabytes
        errors.add(:videos, 'size must be less than 100MB')
      end
    end
  end

  def validate_audio_recordings
    return unless audio_recordings.attached?

    audio_recordings.each do |audio|
      unless audio.blob.content_type.in?(%w[audio/mpeg audio/mp3 audio/wav audio/webm audio/ogg])
        errors.add(:audio_recordings, 'must be MP3, WAV, WebM, or OGG')
      end

      if audio.blob.byte_size > 20.megabytes
        errors.add(:audio_recordings, 'size must be less than 20MB')
      end
    end
  end
end
