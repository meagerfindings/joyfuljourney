class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :require_login, :admin?, :manager_or_admin?, 
                :turbo_native_app?, :turbo_native_ios?, :turbo_native_android?, :current_user_json
  
  before_action :set_current_user_for_javascript

  # Support both session and token authentication
  def current_user
    @_current_user ||= begin
      if session[:user_id]
        User.find(session[:user_id])
      elsif request.headers['Authorization'].present?
        authenticate_with_token
      end
    end
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

    if post.private?
      flash[:error] = 'You can only access your own private posts.'
      redirect_to root_path
    elsif current_user&.family != post.user.family || current_user&.family.blank?
      flash[:error] = 'You can only access posts from your family members.'
      redirect_to root_path
    end
  end

  # Turbo Native helpers
  def turbo_native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end

  def turbo_native_ios?
    turbo_native_app? && request.user_agent.to_s.include?("iOS")
  end

  def turbo_native_android?
    turbo_native_app? && request.user_agent.to_s.include?("Android")
  end

  private

  def authenticate_with_token
    token = request.headers['Authorization'].to_s.split(' ').last
    User.find_by(authentication_token: token) if token.present?
  end
  
  def set_current_user_for_javascript
    @current_user_json = current_user_json if logged_in?
  end
  
  def current_user_json
    return nil unless current_user
    
    {
      id: current_user.id,
      username: current_user.username,
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      name: current_user.name,
      role: current_user.role
    }.to_json
  end
end
