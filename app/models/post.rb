class Post < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  belongs_to :user
  has_and_belongs_to_many :tagged_users, class_name: 'User'
  has_many :milestones, as: :milestoneable, dependent: :destroy
  has_many :reactions, dependent: :destroy

  scope :visible_to_family, ->(family) { 
    joins(:user).where(users: { family: family }).where(private: false)
  }

  scope :private_posts, -> { where(private: true) }
  scope :public_posts, -> { where(private: false) }

  def reaction_counts
    reactions.group(:reaction_type).count
  end

  def user_reaction(user)
    reactions.find_by(user: user)
  end

  def total_reactions
    reactions.count
  end
end
