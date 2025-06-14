class User < ApplicationRecord
  attr_reader :name

  before_validation :set_random_password, on: :create, unless: %i[claimed password]
  before_validation :set_random_username, on: :create, unless: %i[claimed username]

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, if: :claimed

  before_save :downcase_username

  has_many :posts
  has_secure_password

  enum role: %w[default manager admin]

  def name
    "#{first_name} #{last_name}"
  end

  def post_count
    Post.where(user_id: id).count
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
