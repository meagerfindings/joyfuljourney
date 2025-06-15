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
    end
  end

  def show; end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if validate_tagged_users && @post.save
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Memory was successfully created! 🎉' }
        format.turbo_stream { redirect_to @post }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("post_form", partial: "form", locals: { post: @post }) }
      end
    end
  end

  def edit; end

  def update
    if validate_tagged_users && @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Memory was successfully updated! ✨' }
        format.turbo_stream { redirect_to @post }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("post_form", partial: "form", locals: { post: @post }) }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_path, notice: 'Memory was successfully deleted.', status: :see_other }
      format.turbo_stream { redirect_to posts_path, status: :see_other }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_action
    authorize_post_access(@post)
  end

  def post_params
    params.require(:post).permit(:title, :body, :private, tagged_user_ids: [])
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
