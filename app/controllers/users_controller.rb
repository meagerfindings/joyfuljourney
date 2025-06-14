class UsersController < ApplicationController
  before_action :require_login, except: %i[new create login_form login]
  before_action :require_manager_or_admin, only: %i[index destroy]
  before_action :set_user, only: %i[show edit update destroy]
  before_action :authorize_user_action, only: %i[show edit update]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show; end

  def new
    claimed_status = !!params[:claimed]
    @user = User.new(claimed: claimed_status)
  end

  def create
    @user = User.new(user_params)

    return render :new, status: :unprocessable_entity unless @user.save

    if @user.claimed # newly created and claimed/registered user
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}!"
      redirect_to root_path
    else # created, but not claimed user
      redirect_to @user
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def login_form; end

  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Welcome, #{user.name}!"
      redirect_to root_path
    else
      flash[:error] = 'Sorry, your username or password did not match what we have on record.'
      render :login_form
    end
  end

  def logout
    session.delete :user_id
    redirect_to root_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user_action
    authorize_user_access(@user)
  end

  def user_params
    permitted_params = %i[first_name last_name middle_name birthdate nickname claimed]

    if params[:user][:claimed]
      permitted_params << :username
      permitted_params << :password
    end

    params.require(:user).permit(permitted_params)
  end
end
