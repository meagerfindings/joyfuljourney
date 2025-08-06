module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_with_token, only: [:create]
      
      def create
        user = User.find_by(username: params[:username])
        
        if user&.authenticate(params[:password])
          user.regenerate_authentication_token unless user.authentication_token
          
          render json: {
            token: user.authentication_token,
            user: user_json(user)
          }
        else
          render json: { error: 'Invalid username or password' }, status: :unauthorized
        end
      end
      
      def destroy
        current_user.update(authentication_token: nil) if current_user
        head :no_content
      end
      
      private
      
      def user_json(user)
        {
          id: user.id,
          username: user.username,
          first_name: user.first_name,
          last_name: user.last_name,
          name: user.name,
          role: user.role,
          claimed: user.claimed
        }
      end
    end
  end
end