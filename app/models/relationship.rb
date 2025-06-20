class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :related_user, class_name: 'User'

  validates :relationship_type, presence: true
  validates :user_id, uniqueness: { scope: :related_user_id }
  validate :cannot_relate_to_self
  validate :valid_relationship_type

  RELATIONSHIP_TYPES = %w[
    parent child sibling spouse partner
    grandparent grandchild aunt_uncle niece_nephew
    cousin friend
  ].freeze

  scope :of_type, ->(type) { where(relationship_type: type) }
  scope :for_user, ->(user) { where(user:) }

  def self.bidirectional_create(user, related_user, relationship_type)
    inverse_type = inverse_relationship_type(relationship_type)

    transaction do
      create!(user:, related_user:, relationship_type:)
      create!(user: related_user, related_user: user, relationship_type: inverse_type) if inverse_type
    end
  end

  def self.inverse_relationship_type(type)
    case type
    when 'parent' then 'child'
    when 'child' then 'parent'
    when 'grandparent' then 'grandchild'
    when 'grandchild' then 'grandparent'
    when 'aunt_uncle' then 'niece_nephew'
    when 'niece_nephew' then 'aunt_uncle'
    when 'sibling', 'spouse', 'partner', 'cousin', 'friend' then type
    end
  end

  private

  def cannot_relate_to_self
    errors.add(:related_user, 'cannot be the same as user') if user_id == related_user_id
  end

  def valid_relationship_type
    return if RELATIONSHIP_TYPES.include?(relationship_type)

    errors.add(:relationship_type, "must be one of: #{RELATIONSHIP_TYPES.join(', ')}")
  end
end
