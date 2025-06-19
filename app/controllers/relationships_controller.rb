class RelationshipsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_relationship, only: [:show, :destroy]
  before_action :authorize_relationship_management
  
  def index
    @relationships = @user.all_relationships
    @suggested_relationships = @user.suggested_relationships
    @family_members = @user.family_members.where.not(id: @user.related_users.pluck(:id))
  end
  
  def new
    @relationship = @user.relationships.build
    @available_users = @user.family_members
  end
  
  def create
    @relationship = @user.relationships.build(relationship_params)
    
    if @relationship.save
      flash[:success] = "Relationship added successfully!"
      redirect_to user_relationships_path(@user)
    else
      @available_users = @user.family_members
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    # For displaying relationship details
  end
  
  def destroy
    @relationship.destroy
    flash[:success] = "Relationship removed."
    redirect_to user_relationships_path(@user)
  end
  
  def family_tree
    @user = User.find(params[:user_id])
    @family_tree_data = build_family_tree_for(@user)
    
    respond_to do |format|
      format.html
      format.json { render json: @family_tree_data }
    end
  end
  
  def suggestions
    @user = User.find(params[:user_id])
    @suggestions = @user.suggested_relationships
    
    respond_to do |format|
      format.html
      format.json { render json: @suggestions }
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:user_id])
  end
  
  def set_relationship
    @relationship = @user.relationships.find(params[:id])
  end
  
  def authorize_relationship_management
    unless current_user == @user || current_user.manager_or_admin?
      flash[:error] = "You can only manage your own relationships."
      redirect_to root_path
    end
  end
  
  def relationship_params
    params.require(:relationship).permit(:related_user_id, :relationship_type)
  end
  
  def build_family_tree_for(user, visited = Set.new)
    return nil if visited.include?(user.id)
    visited.add(user.id)
    
    tree_data = {
      id: user.id,
      name: user.name,
      birthdate: user.birthdate,
      relationships: {}
    }
    
    # Add parents
    tree_data[:relationships][:parents] = user.parents.map do |parent|
      build_family_tree_for(parent, visited)
    end.compact
    
    # Add children
    tree_data[:relationships][:children] = user.children.map do |child|
      build_family_tree_for(child, visited)
    end.compact
    
    # Add spouse
    if user.spouse
      tree_data[:relationships][:spouse] = {
        id: user.spouse.id,
        name: user.spouse.name,
        birthdate: user.spouse.birthdate
      }
    end
    
    # Add siblings
    tree_data[:relationships][:siblings] = user.siblings.map do |sibling|
      {
        id: sibling.id,
        name: sibling.name,
        birthdate: sibling.birthdate
      }
    end
    
    tree_data
  end
end