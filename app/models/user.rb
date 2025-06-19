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
  has_many :reactions, dependent: :destroy
  
  has_many :relationships, dependent: :destroy
  has_many :inverse_relationships, class_name: 'Relationship', foreign_key: 'related_user_id', dependent: :destroy
  has_many :related_users, through: :relationships, source: :related_user
  
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
  
  def parents
    related_users_by_type('parent')
  end
  
  def children
    related_users_by_type('child')
  end
  
  def siblings
    related_users_by_type('sibling')
  end
  
  def spouse
    related_users_by_type('spouse').first
  end
  
  def grandparents
    related_users_by_type('grandparent')
  end
  
  def grandchildren
    related_users_by_type('grandchild')
  end
  
  def all_relationships
    Relationship.where('user_id = ? OR related_user_id = ?', id, id)
                .includes(:user, :related_user)
  end
  
  def related_to?(other_user)
    relationships.exists?(related_user_id: other_user.id) ||
      inverse_relationships.exists?(user_id: other_user.id)
  end
  
  def relationship_with(other_user)
    relationships.find_by(related_user_id: other_user.id) ||
      inverse_relationships.find_by(user_id: other_user.id)
  end
  
  def relationship_type_with(other_user)
    relationship_with(other_user)&.relationship_type
  end
  
  def suggested_relationships
    return [] unless family
    
    # Get family members who are not yet related
    unrelated_family_members = family.users
                                    .where.not(id: id)
                                    .where.not(id: related_users.pluck(:id))
                                    .where.not(id: inverse_relationships.pluck(:user_id))
    
    # Suggest relationships based on age and existing relationships
    suggestions = []
    
    unrelated_family_members.each do |member|
      suggested_type = suggest_relationship_type_for(member)
      suggestions << { user: member, suggested_type: suggested_type } if suggested_type
    end
    
    suggestions
  end
  
  def family_tree_data
    {
      id: id,
      name: name,
      birthdate: birthdate,
      relationships: relationships.includes(:related_user).map do |rel|
        {
          type: rel.relationship_type,
          related_user_id: rel.related_user_id,
          related_user_name: rel.related_user.name
        }
      end
    }
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
  
  def related_users_by_type(type)
    User.joins(:inverse_relationships)
        .where(relationships: { user_id: id, relationship_type: type })
  end
  
  def suggest_relationship_type_for(other_user)
    return nil unless birthdate && other_user.birthdate
    
    age_diff = (birthdate - other_user.birthdate).to_i / 365
    
    # Check for parent/child
    if age_diff.abs > 15 && age_diff.abs < 50
      return age_diff > 0 ? 'child' : 'parent'
    end
    
    # Check for siblings
    if age_diff.abs < 15
      # Check if they share parents
      if (parents & other_user.parents).any?
        return 'sibling'
      end
      return 'sibling' # Could be step-sibling or cousin
    end
    
    # Check for grandparent/grandchild
    if age_diff.abs > 40
      return age_diff > 0 ? 'grandchild' : 'grandparent'
    end
    
    nil
  end
end
