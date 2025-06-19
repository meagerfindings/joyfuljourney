class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :reaction_type, presence: true
  validates :user_id, uniqueness: { scope: :post_id }
  validate :valid_reaction_type

  REACTION_TYPES = %w[
    heart like love laugh wow sad angry
    celebrate party clap thumbs_up thumbs_down
  ].freeze

  REACTION_EMOJIS = {
    'heart' => '❤️',
    'like' => '👍',
    'love' => '😍',
    'laugh' => '😂',
    'wow' => '😲',
    'sad' => '😢',
    'angry' => '😡',
    'celebrate' => '🎉',
    'party' => '🥳',
    'clap' => '👏',
    'thumbs_up' => '👍',
    'thumbs_down' => '👎'
  }.freeze

  scope :of_type, ->(type) { where(reaction_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  def emoji
    REACTION_EMOJIS[reaction_type] || '👍'
  end

  def display_name
    reaction_type.humanize
  end

  private

  def valid_reaction_type
    return if REACTION_TYPES.include?(reaction_type)

    errors.add(:reaction_type, "must be one of: #{REACTION_TYPES.join(', ')}")
  end
end