class Family < ApplicationRecord
  validates :name, presence: true

  has_many :users, dependent: :destroy
  has_many :posts, through: :users
  has_many :milestones, as: :milestoneable, dependent: :destroy
  has_many :family_invitations, dependent: :destroy
  
  def pending_invitations
    family_invitations.active
  end
  
  def admin_users
    users.where(role: ['admin', 'manager'])
  end
end