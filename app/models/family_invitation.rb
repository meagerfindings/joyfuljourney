class FamilyInvitation < ApplicationRecord
  belongs_to :family
  belongs_to :inviter, class_name: 'User'
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :email, uniqueness: { scope: :family_id, message: "has already been invited to this family" }
  
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  
  enum status: {
    pending: 0,
    accepted: 1, 
    declined: 2,
    expired: 3,
    cancelled: 4
  }
  
  scope :active, -> { where(status: :pending).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  
  def expired?
    expires_at <= Time.current
  end
  
  def accept!
    return false if expired? || !pending?
    
    transaction do
      update!(status: :accepted)
      expire_other_invitations_for_email
    end
  end
  
  def decline!
    return false if expired? || !pending?
    
    update!(status: :declined)
  end
  
  def cancel!
    return false unless pending?
    
    update!(status: :cancelled)
  end
  
  def expire!
    update!(status: :expired) if pending?
  end
  
  def family_name
    family&.name
  end
  
  def inviter_name
    inviter&.name
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_expiration
    self.expires_at = 7.days.from_now
  end
  
  def expire_other_invitations_for_email
    FamilyInvitation.where(email: email)
                   .where.not(id: id)
                   .pending
                   .update_all(status: :expired)
  end
end
