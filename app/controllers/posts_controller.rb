# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_post_action, only: %i[edit update destroy]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = visible_posts_for_user(@user)
    else
      @posts = visible_posts_for_current_user
      
      # Filter by tagged user if specified
      if params[:tagged_user_id].present?
        tagged_user = User.find(params[:tagged_user_id])
        # Ensure the tagged user is in the current user's family
        if current_user&.family == tagged_user.family
          @posts = @posts.joins(:tagged_users).where(users: { id: tagged_user.id }).distinct
        end
      end
    end
  end

  def show
    @post.milestones.includes(:created_by_user)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if validate_tagged_users && @post.save
      redirect_to @post, notice: 'Memory was successfully created! 🎉'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if validate_tagged_users && @post.update(post_params)
      redirect_to @post, notice: 'Memory was successfully updated! ✨'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Memory was successfully deleted.', status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_action
    authorize_post_access(@post)
  end

  def post_params
    params.require(:post).permit(:title, :body, :private, tagged_user_ids: [], photos: [], videos: [], audio_recordings: [])
  end

  def visible_posts_for_user(user)
    if current_user&.family == user.family && current_user.family.present?
      user.posts.public_posts
    elsif current_user == user
      user.posts
    else
      Post.none
    end
  end

  def visible_posts_for_current_user
    if current_user&.family.present?
      Post.visible_to_family(current_user.family)
    else
      Post.public_posts
    end
  end

  def validate_tagged_users
    return true unless params[:post][:tagged_user_ids].present?

    tagged_user_ids = params[:post][:tagged_user_ids].reject(&:blank?)
    return true if tagged_user_ids.empty?

    # Ensure all tagged users are family members
    family_member_ids = current_user.family_members.pluck(:id).map(&:to_s)
    invalid_tags = tagged_user_ids - family_member_ids

    if invalid_tags.any?
      @post.errors.add(:tagged_users, 'can only include family members')
      return false
    end

    true
  end
end
