class UsersController < ApplicationController
  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
  end
  def new
    claimed_status = !!params[:claimed]
    @user = User.new(claimed: claimed_status)
  end

  def create
    @user = User.new(user_params)

    return render :new, status: :unprocessable_entity unless @user.save

    if @user.claimed # newly created and claimed/registered user
      flash[:success] = "Welcome, #{@user.name}!"
      redirect_to root_path
    else # created, but not claimed user
      redirect_to @user
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to User
  end

  private
  def user_params
    permitted_params = [:first_name, :last_name, :middle_name, :birthdate, :nickname, :claimed]

    if params[:user][:claimed]
      permitted_params << :username
      permitted_params << :password
    end

    params.require(:user).permit(permitted_params)
  end
end
