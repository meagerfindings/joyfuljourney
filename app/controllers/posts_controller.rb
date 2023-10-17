# frozen_string_literal: true
class PostsController < ApplicationController
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @user.post
    else
      @posts = Post.all
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create

    # TODO: Remove the hardcoding of user_id once authentication is added
    modified_params = post_params
    unless modified_params[:user_id].present?
      modified_params[:user_id] = User.last.id
    end

    @post = Post.new(modified_params)

    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if @post.update(post_params)
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to root_path, status: :see_other
  end

  private
  def post_params
    params.require(:post).permit(:title, :body, :user_id)
  end
end
