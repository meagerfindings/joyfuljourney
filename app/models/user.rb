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
  has_secure_password

  enum role: %w[default manager admin]

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
end
