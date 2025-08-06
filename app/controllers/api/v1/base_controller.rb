module Api
  module V1
    class BaseController < ApplicationController
      include ApiAuthenticatable
      
      skip_before_action :verify_authenticity_token
      before_action :set_default_format
      
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      
      private
      
      def set_default_format
        request.format = :json
      end
      
      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end
      
      def unprocessable_entity(exception)
        render json: { 
          error: "Validation failed",
          errors: exception.record.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end
  end
end