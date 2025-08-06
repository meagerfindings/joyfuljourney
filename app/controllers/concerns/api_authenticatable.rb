module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_token
  end

  private

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)
      if user
        @current_user = user
        true
      else
        false
      end
    end
  end

  def current_user
    @current_user
  end
end