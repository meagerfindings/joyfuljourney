class TurboController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def ios_path_configuration
    render json: load_path_configuration(:ios)
  end
  
  def android_path_configuration
    render json: load_path_configuration(:android)
  end
  
  private
  
  def load_path_configuration(platform)
    file_path = Rails.root.join("config", "turbo", "#{platform}_path_configuration.json")
    
    if File.exist?(file_path)
      JSON.parse(File.read(file_path))
    else
      # Fallback configuration if file doesn't exist
      default_path_configuration
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing path configuration for #{platform}: #{e.message}"
    default_path_configuration
  end
  
  def default_path_configuration
    {
      settings: {
        pull_to_refresh_enabled: true,
        show_bars_on_scroll: true
      },
      rules: [
        {
          patterns: [".*"],
          properties: {
            presentation: "push",
            pull_to_refresh_enabled: true
          }
        }
      ]
    }
  end
end