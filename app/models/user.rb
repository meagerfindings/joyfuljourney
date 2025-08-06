class User < ApplicationRecord
  before_validation :set_random_password, on: :create, unless: %i[claimed password]
  before_validation :set_random_username, on: :create, unless: %i[claimed username]

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, if: :claimed

  before_save :downcase_username

  has_many :posts
  belongs_to :family, optional: true
  has_and_belongs_to_many :tagged_posts, class_name: 'Post'
  has_many :milestones, as: :milestoneable, dependent: :destroy
  has_many :created_milestones, class_name: 'Milestone', foreign_key: 'created_by_user_id', dependent: :destroy
  
  has_many :relationships, dependent: :destroy
  has_many :inverse_relationships, class_name: 'Relationship', foreign_key: 'related_user_id', dependent: :destroy
  has_many :related_users, through: :relationships, source: :related_user
  has_secure_password

  enum role: %w[default manager admin]

  # Token authentication for mobile apps
  before_create :generate_authentication_token

  def name
    "#{first_name} #{last_name}"
  end

  def post_count
    Post.where(user_id: id).count
  end

  def age
    return nil unless birthdate

    ((Date.current - birthdate) / 365.25).floor
  end

  def age_in_months
    return nil unless birthdate

    ((Date.current - birthdate) / 30.44).floor # Average days per month
  end

  def display_age
    return nil unless birthdate

    years = age
    months = age_in_months
    days = (Date.current - birthdate).to_i

    if years >= 1
      "#{years} #{'year'.pluralize(years)} old"
    elsif months >= 1
      "#{months} #{'month'.pluralize(months)} old"
    elsif days >= 1
      "#{days} #{'day'.pluralize(days)} old"
    end
  end

  def family_members
    return User.none unless family

    family.users.where.not(id:)
  end

  def all_related_users
    User.joins("LEFT JOIN relationships ON relationships.related_user_id = users.id")
        .where("relationships.user_id = ? OR users.id IN (?)", id, related_users.pluck(:id))
        .where.not(id: id)
        .distinct
  end

  def related_posts
    Post.joins(:user)
        .where(users: { id: related_users.pluck(:id) })
        .where(private: false)
        .order(created_at: :desc)
  end

  def relationship_with(other_user)
    relationships.find_by(related_user: other_user)
  end

  def relationship_type_with(other_user)
    relationship_with(other_user)&.relationship_type
  end

  # Generate new authentication token
  def regenerate_authentication_token
    self.authentication_token = generate_token
    save
  end

  private

  # https://stackoverflow.com/a/34391252
  def set_random_password
    self.password = random_value
  end

  def set_random_username
    self.username = random_value.downcase
  end

  def random_value
    SecureRandom.base64(100)[0, 72]
  end

  def downcase_username
    self.username = username.downcase if username.present?
  end

  def generate_authentication_token
    self.authentication_token = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex(32)
      break token unless User.exists?(authentication_token: token)
    end
  end
end
