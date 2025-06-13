class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :require_login, :admin?, :manager_or_admin?

  def current_user
    @_current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    return if logged_in?

    flash[:error] = 'You must be logged in to access this page.'
    redirect_to login_path
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def manager_or_admin?
    logged_in? && (current_user.manager? || current_user.admin?)
  end

  def require_admin
    return if admin?

    flash[:error] = 'You must be an admin to access this page.'
    redirect_to root_path
  end

  def require_manager_or_admin
    return if manager_or_admin?

    flash[:error] = 'You must be a manager or admin to access this page.'
    redirect_to root_path
  end

  def authorize_user_access(user)
    return if current_user == user || manager_or_admin?

    flash[:error] = 'You can only access your own profile.'
    redirect_to root_path
  end

  def authorize_post_access(post)
    return if current_user == post.user || manager_or_admin?

    flash[:error] = 'You can only access your own posts.'
    redirect_to root_path
  end
end
