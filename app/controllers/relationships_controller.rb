class RelationshipsController < ApplicationController
  before_action :require_login
  before_action :set_relationship, only: %i[show destroy]

  def index
    @relationships = current_user.relationships.includes(:related_user)
    @users = User.where.not(id: current_user.id)
                 .where.not(id: current_user.related_users.pluck(:id))
  end

  def show; end

  def new
    @relationship = current_user.relationships.build
    @users = User.where.not(id: current_user.id)
                 .where.not(id: current_user.related_users.pluck(:id))
  end

  def create
    @related_user = User.find(relationship_params[:related_user_id])

    begin
      Relationship.bidirectional_create(
        current_user,
        @related_user,
        relationship_params[:relationship_type]
      )
      redirect_to relationships_path, notice: "Relationship with #{@related_user.name} created successfully."
    rescue ActiveRecord::RecordInvalid => e
      @relationship = current_user.relationships.build(relationship_params)
      @users = User.where.not(id: current_user.id)
                   .where.not(id: current_user.related_users.pluck(:id))
      flash.now[:alert] = "Error creating relationship: #{e.message}"
      render :new
    end
  end

  def destroy
    related_user = @relationship.related_user

    Relationship.transaction do
      @relationship.destroy
      Relationship.find_by(user: related_user, related_user: current_user)&.destroy
    end

    redirect_to relationships_path, notice: "Relationship with #{related_user.name} removed."
  end

  private

  def set_relationship
    @relationship = current_user.relationships.find(params[:id])
  end

  def relationship_params
    params.require(:relationship).permit(:related_user_id, :relationship_type)
  end

  def require_login
    return if current_user

    redirect_to login_path, alert: 'Please log in to manage relationships.'
  end
end
