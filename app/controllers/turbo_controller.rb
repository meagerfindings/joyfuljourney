class TurboController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def ios_path_configuration
    render json: path_configuration_json(:ios)
  end
  
  def android_path_configuration
    render json: path_configuration_json(:android)
  end
  
  private
  
  def path_configuration_json(platform)
    {
      settings: {
        pull_to_refresh_enabled: true,
        show_bars_on_scroll: true
      },
      rules: [
        {
          patterns: ["/login", "/users/new"],
          properties: {
            presentation: "modal",
            pull_to_refresh_enabled: false
          }
        },
        {
          patterns: ["/posts/new", "/posts/*/edit"],
          properties: {
            presentation: "modal",
            pull_to_refresh_enabled: false
          }
        },
        {
          patterns: ["/users/*/edit"],
          properties: {
            presentation: "modal"
          }
        },
        {
          patterns: ["/families/new", "/families/*/edit"],
          properties: {
            presentation: "modal"
          }
        },
        {
          patterns: ["/milestones/new", "/milestones/*/edit"],
          properties: {
            presentation: "modal"
          }
        },
        {
          patterns: ["/"],
          properties: {
            presentation: "default",
            pull_to_refresh_enabled: true,
            tab: "home"
          }
        },
        {
          patterns: ["/posts"],
          properties: {
            presentation: "default",
            pull_to_refresh_enabled: true,
            tab: "posts"
          }
        },
        {
          patterns: ["/timeline"],
          properties: {
            presentation: "default",
            pull_to_refresh_enabled: true,
            tab: "timeline"
          }
        },
        {
          patterns: ["/users/*"],
          properties: {
            presentation: "default",
            tab: "profile"
          }
        }
      ]
    }
  end
end