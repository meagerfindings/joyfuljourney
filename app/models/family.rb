class Family < ApplicationRecord
  validates :name, presence: true

  has_many :users, dependent: :destroy
  has_many :posts, through: :users
  has_many :milestones, as: :milestoneable, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
end