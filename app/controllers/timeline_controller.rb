class TimelineController < ApplicationController
  before_action :require_login

  def index
    @timeline_items = fetch_timeline_items
    @filter_type = params[:filter_type] || 'all'
    @filter_milestone_type = params[:filter_milestone_type]
    
    # Apply filters
    @timeline_items = filter_by_type(@timeline_items, @filter_type)
    @timeline_items = filter_by_milestone_type(@timeline_items, @filter_milestone_type)
    
    # Sort by date descending (most recent first)
    @timeline_items = @timeline_items.sort_by { |item| item_date(item) }.reverse
    
    @milestone_types = Milestone::MILESTONE_TYPES
  end

  def show_truncated
    @timeline_items = fetch_timeline_items.first(5)
    @timeline_items = @timeline_items.sort_by { |item| item_date(item) }.reverse
    render :truncated
  end

  private

  def fetch_timeline_items
    items = []
    
    # Get milestones
    milestones = if current_user.family
                   visible_family_milestones
                 else
                   current_user.milestones
                 end
    
    milestones = milestones.select { |milestone| milestone.visible_to?(current_user) }
    items.concat(milestones)
    
    # Get posts
    posts = if current_user.family
              visible_family_posts
            else
              current_user.posts
            end
    
    items.concat(posts)
    items
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
        .includes(:user, :tagged_users, photos_attachments: :blob, videos_attachments: :blob, audio_recordings_attachments: :blob)
  end

  def filter_by_type(items, filter_type)
    case filter_type
    when 'posts'
      items.select { |item| item.is_a?(Post) }
    when 'milestones'  
      items.select { |item| item.is_a?(Milestone) }
    else
      items
    end
  end

  def filter_by_milestone_type(items, milestone_type)
    return items unless milestone_type.present?
    
    items.select do |item|
      item.is_a?(Post) || (item.is_a?(Milestone) && item.milestone_type == milestone_type)
    end
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