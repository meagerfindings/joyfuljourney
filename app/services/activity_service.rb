class ActivityService
  class << self
    def track_post_activity(post, activity_type, user = nil)
      user ||= post.user
      
      Activity.create!(
        user: user,
        trackable: post,
        activity_type: Activity::TYPES[activity_type],
        occurred_at: Time.current,
        data: build_post_activity_data(post, activity_type)
      )
    end

    def track_milestone_activity(milestone, activity_type, user = nil)
      user ||= milestone.created_by_user
      
      Activity.create!(
        user: user,
        trackable: milestone,
        activity_type: Activity::TYPES[activity_type],
        occurred_at: Time.current,
        data: build_milestone_activity_data(milestone, activity_type)
      )
    end

    def track_reaction_activity(reaction)
      Activity.create!(
        user: reaction.user,
        trackable: reaction.post,
        activity_type: Activity::TYPES[:post_reacted],
        occurred_at: Time.current,
        data: build_reaction_activity_data(reaction)
      )
    end

    def track_user_activity(user, activity_type)
      Activity.create!(
        user: user,
        trackable: user,
        activity_type: Activity::TYPES[activity_type],
        occurred_at: Time.current,
        data: build_user_activity_data(user, activity_type)
      )
    end

    def track_family_activity(family, user, activity_type)
      Activity.create!(
        user: user,
        trackable: family,
        activity_type: Activity::TYPES[activity_type],
        occurred_at: Time.current,
        data: build_family_activity_data(family, user, activity_type)
      )
    end

    def track_tagging_activity(taggable_object, tagger, tagged_users)
      return if tagged_users.empty?

      Activity.create!(
        user: tagger,
        trackable: taggable_object,
        activity_type: Activity::TYPES[:user_tagged],
        occurred_at: Time.current,
        data: build_tagging_activity_data(taggable_object, tagger, tagged_users)
      )
    end

    def get_family_activity_feed(family, limit = 50)
      Activity.joins(:user)
              .where(users: { family: family })
              .recent
              .includes(:user, :trackable)
              .limit(limit)
    end

    def get_user_activity_feed(user, limit = 50)
      Activity.where(user: user)
              .recent
              .includes(:user, :trackable)
              .limit(limit)
    end

    def get_trackable_activity_feed(trackable, limit = 20)
      Activity.where(trackable: trackable)
              .recent
              .includes(:user)
              .limit(limit)
    end

    private

    def build_post_activity_data(post, activity_type)
      {
        post_id: post.id,
        post_title: post.title,
        post_body_preview: post.body.truncate(100),
        family_id: post.user.family_id,
        activity_type: activity_type.to_s
      }.to_json
    end

    def build_milestone_activity_data(milestone, activity_type)
      {
        milestone_id: milestone.id,
        milestone_title: milestone.title,
        milestone_description_preview: milestone.description&.truncate(100),
        family_id: milestone.created_by_user.family_id,
        activity_type: activity_type.to_s
      }.to_json
    end

    def build_reaction_activity_data(reaction)
      {
        reaction_id: reaction.id,
        reaction_type: reaction.reaction_type,
        post_id: reaction.post.id,
        post_title: reaction.post.title,
        post_author: reaction.post.user.name,
        family_id: reaction.user.family_id
      }.to_json
    end

    def build_user_activity_data(user, activity_type)
      {
        user_id: user.id,
        user_name: user.name,
        family_id: user.family_id,
        activity_type: activity_type.to_s
      }.to_json
    end

    def build_family_activity_data(family, user, activity_type)
      {
        family_id: family.id,
        family_name: family.name,
        user_id: user.id,
        user_name: user.name,
        activity_type: activity_type.to_s
      }.to_json
    end

    def build_tagging_activity_data(taggable_object, tagger, tagged_users)
      {
        taggable_type: taggable_object.class.name,
        taggable_id: taggable_object.id,
        taggable_title: taggable_object.respond_to?(:title) ? taggable_object.title : nil,
        tagger_id: tagger.id,
        tagger_name: tagger.name,
        tagged_user_ids: tagged_users.map(&:id),
        tagged_user_names: tagged_users.map(&:name),
        family_id: tagger.family_id
      }.to_json
    end
  end
end