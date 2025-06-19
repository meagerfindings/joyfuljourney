class ActivitiesController < ApplicationController
  before_action :require_login

  def index
    @activities = if current_user.family
                    ActivityService.get_family_activity_feed(current_user.family)
                  else
                    ActivityService.get_user_activity_feed(current_user)
                  end
    
    # Group activities by date for better presentation
    @grouped_activities = @activities.group_by { |activity| activity.occurred_at.to_date }
  end
end
