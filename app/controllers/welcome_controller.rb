class WelcomeController < ApplicationController
  def index
    if current_user
      @timeline_items = fetch_recent_timeline_items
    end
  end

  private

  def fetch_recent_timeline_items
    items = []
    
    # Get recent milestones
    milestones = if current_user.family
                   visible_family_milestones
                 else
                   current_user.milestones
                 end
    
    milestones = milestones.select { |milestone| milestone.visible_to?(current_user) }
    items.concat(milestones)
    
    # Get recent posts
    posts = if current_user.family
              visible_family_posts
            else
              current_user.posts
            end
    
    items.concat(posts)
    
    # Sort by date and limit to 5 most recent
    items.sort_by { |item| item_date(item) }.reverse.first(5)
  end

  def visible_family_milestones
    return Milestone.none unless current_user.family

    family_user_ids = current_user.family.users.pluck(:id)
    family_post_ids = current_user.family.posts.pluck(:id)

    Milestone.where(
      "(milestoneable_type = 'User' AND milestoneable_id IN (?)) OR " \
      "(milestoneable_type = 'Family' AND milestoneable_id = ?) OR " \
      "(milestoneable_type = 'Post' AND milestoneable_id IN (?))",
      family_user_ids, current_user.family.id, family_post_ids
    ).includes(:milestoneable, :created_by_user)
  end

  def visible_family_posts
    return Post.none unless current_user.family
    
    Post.joins(:user)
        .where(users: { family: current_user.family })
        .where(private: false)
        .includes(:user, :tagged_users)
  end

  def item_date(item)
    case item
    when Post
      item.created_at
    when Milestone
      item.milestone_date
    else
      item.created_at
    end
  end
end
