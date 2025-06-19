class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :related_user, class_name: 'User'
  
  validates :user_id, presence: true
  validates :related_user_id, presence: true
  validates :relationship_type, presence: true
  validates :user_id, uniqueness: { scope: :related_user_id }
  validate :cannot_relate_to_self
  
  # Define relationship types
  RELATIONSHIP_TYPES = {
    parent: 'parent',
    child: 'child',
    spouse: 'spouse',
    sibling: 'sibling',
    grandparent: 'grandparent',
    grandchild: 'grandchild',
    aunt_uncle: 'aunt_uncle',
    niece_nephew: 'niece_nephew',
    cousin: 'cousin',
    step_parent: 'step_parent',
    step_child: 'step_child',
    step_sibling: 'step_sibling',
    parent_in_law: 'parent_in_law',
    child_in_law: 'child_in_law',
    sibling_in_law: 'sibling_in_law',
    guardian: 'guardian',
    ward: 'ward'
  }.freeze
  
  # Define inverse relationships
  INVERSE_RELATIONSHIPS = {
    parent: :child,
    child: :parent,
    spouse: :spouse,
    sibling: :sibling,
    grandparent: :grandchild,
    grandchild: :grandparent,
    aunt_uncle: :niece_nephew,
    niece_nephew: :aunt_uncle,
    cousin: :cousin,
    step_parent: :step_child,
    step_child: :step_parent,
    step_sibling: :step_sibling,
    parent_in_law: :child_in_law,
    child_in_law: :parent_in_law,
    sibling_in_law: :sibling_in_law,
    guardian: :ward,
    ward: :guardian
  }.freeze
  
  # Scopes
  scope :family_relationships, -> { where(relationship_type: ['parent', 'child', 'sibling', 'grandparent', 'grandchild']) }
  scope :extended_family, -> { where(relationship_type: ['aunt_uncle', 'niece_nephew', 'cousin']) }
  scope :in_law_relationships, -> { where(relationship_type: ['parent_in_law', 'child_in_law', 'sibling_in_law']) }
  
  # Callbacks
  after_create :create_inverse_relationship
  after_destroy :destroy_inverse_relationship
  
  def relationship_display_name
    case relationship_type
    when 'parent'
      related_user.birthdate && user.birthdate && related_user.birthdate < user.birthdate ? 
        (related_user.nickname || related_user.first_name || 'Parent') : 'Parent'
    when 'child'
      related_user.nickname || related_user.first_name || 'Child'
    when 'spouse'
      'Spouse'
    when 'sibling'
      'Sibling'
    when 'grandparent'
      'Grandparent'
    when 'grandchild'
      'Grandchild'
    when 'aunt_uncle'
      related_user.birthdate && user.birthdate && related_user.birthdate < user.birthdate ? 
        (related_user.gender == 'female' ? 'Aunt' : 'Uncle') : 'Aunt/Uncle'
    when 'niece_nephew'
      related_user.gender == 'female' ? 'Niece' : 'Nephew'
    when 'cousin'
      'Cousin'
    when 'step_parent'
      'Step-parent'
    when 'step_child'
      'Step-child'
    when 'step_sibling'
      'Step-sibling'
    when 'parent_in_law'
      related_user.gender == 'female' ? 'Mother-in-law' : 'Father-in-law'
    when 'child_in_law'
      related_user.gender == 'female' ? 'Daughter-in-law' : 'Son-in-law'
    when 'sibling_in_law'
      related_user.gender == 'female' ? 'Sister-in-law' : 'Brother-in-law'
    when 'guardian'
      'Guardian'
    when 'ward'
      'Ward'
    else
      relationship_type.humanize
    end
  end
  
  def inverse_relationship_type
    INVERSE_RELATIONSHIPS[relationship_type.to_sym]
  end
  
  private
  
  def cannot_relate_to_self
    errors.add(:related_user_id, "can't be the same as user") if user_id == related_user_id
  end
  
  def create_inverse_relationship
    return if inverse_relationship_exists?
    
    Relationship.create!(
      user_id: related_user_id,
      related_user_id: user_id,
      relationship_type: inverse_relationship_type
    )
  end
  
  def destroy_inverse_relationship
    inverse = Relationship.find_by(
      user_id: related_user_id,
      related_user_id: user_id,
      relationship_type: inverse_relationship_type
    )
    inverse&.destroy
  end
  
  def inverse_relationship_exists?
    Relationship.exists?(
      user_id: related_user_id,
      related_user_id: user_id,
      relationship_type: inverse_relationship_type
    )
  end
end