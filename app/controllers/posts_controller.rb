# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_post_action, only: %i[edit update destroy]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @user.posts
    else
      @posts = Post.all
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
    params.require(:post).permit(:title, :body)
  end
end
