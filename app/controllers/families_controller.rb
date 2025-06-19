class FamiliesController < ApplicationController
  before_action :require_login
  before_action :set_family, only: %i[show edit update destroy]
  before_action :authorize_family_access, only: %i[show edit update destroy]

  def index
    @families = current_user.admin? ? Family.all : [current_user.family].compact
  end

  def show
    @family_members = @family.users
    @family_posts = Post.visible_to_family(@family).includes(:user)
  end

  def new
    redirect_to @family if current_user.family.present?
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)

    if @family.save
      current_user.update(family: @family)
      current_user.reload  # Reload to ensure family association is fresh
      
      # Track activity
      ActivityService.track_family_activity(@family, current_user, :family_joined)
      
      redirect_to @family, notice: 'Family was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @family.update(family_params)
      redirect_to @family, notice: 'Family was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family.destroy
    redirect_to families_path, notice: 'Family was successfully deleted.'
  end

  private

  def set_family
    @family = Family.find(params[:id])
  end

  def authorize_family_access
    return if current_user.family == @family || admin?

    flash[:error] = 'You can only access your own family.'
    redirect_to root_path
  end

  def family_params
    params.require(:family).permit(:name)
  end
end