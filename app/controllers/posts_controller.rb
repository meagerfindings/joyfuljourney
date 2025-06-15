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

    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_action
    authorize_post_access(@post)
  end

  def post_params
    params.require(:post).permit(:title, :body, :private)
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
end
