class MilestonesController < ApplicationController
  before_action :require_login
  before_action :set_milestone, only: [:show, :edit, :update, :destroy]
  before_action :set_milestoneable, only: [:index, :new, :create]
  before_action :authorize_milestone_access, only: [:show, :edit, :update, :destroy]

  def index
    @milestones = if @milestoneable
                    @milestoneable.milestones.includes(:created_by_user)
                  else
                    current_user.family ? visible_family_milestones : current_user.milestones
                  end
    
    @milestones = @milestones.select { |milestone| milestone.visible_to?(current_user) }
                             .sort_by(&:milestone_date)
                             .reverse
  end

  def show
  end

  def new
    @milestone = (@milestoneable&.milestones || Milestone).build
    @milestone_types = Milestone::MILESTONE_TYPES
  end

  def create
    @milestone = if @milestoneable
                   @milestoneable.milestones.build(milestone_params)
                 else
                   Milestone.new(milestone_params)
                 end
    
    @milestone.created_by_user = current_user

    if @milestone.save
      redirect_to @milestone, notice: 'Milestone was successfully created.'
    else
      @milestone_types = Milestone::MILESTONE_TYPES
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @milestone_types = Milestone::MILESTONE_TYPES
  end

  def update
    if @milestone.update(milestone_params)
      redirect_to @milestone, notice: 'Milestone was successfully updated.'
    else
      @milestone_types = Milestone::MILESTONE_TYPES
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @milestone.destroy
    redirect_to milestones_url, notice: 'Milestone was successfully deleted.'
  end

  private

  def set_milestone
    @milestone = Milestone.find(params[:id])
  end

  def set_milestoneable
    if params[:user_id]
      @milestoneable = User.find(params[:user_id])
    elsif params[:family_id]
      @milestoneable = Family.find(params[:family_id])
    elsif params[:post_id]
      @milestoneable = Post.find(params[:post_id])
    end
  end

  def milestone_params
    params.require(:milestone).permit(:title, :description, :milestone_date, :milestone_type, :is_private, :milestoneable_type, :milestoneable_id)
  end

  def authorize_milestone_access
    unless @milestone.visible_to?(current_user) || manager_or_admin?
      flash[:error] = 'You do not have permission to access this milestone.'
      redirect_to root_path
    end
  end

  def visible_family_milestones
    return Milestone.none unless current_user.family

    family_user_ids = current_user.family.users.pluck(:id)
    family_post_ids = current_user.family.posts.pluck(:id)

    Milestone.where(
      "(milestoneable_type = 'User' AND milestoneable_id IN (?)) OR " \
      "(milestoneable_type = 'Family' AND milestoneable_id = ?) OR " \
      "(milestoneable_type = 'Post' AND milestoneable_id IN (?))",
      family_user_ids, current_user.family.id, family_post_ids
    ).includes(:milestoneable, :created_by_user)
  end
end
