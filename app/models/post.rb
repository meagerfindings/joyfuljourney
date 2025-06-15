class Post < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  belongs_to :user

  scope :visible_to_family, ->(family) { 
    joins(:user).where(users: { family: family }).where(private: false)
  }

  scope :private_posts, -> { where(private: true) }
  scope :public_posts, -> { where(private: false) }
end
