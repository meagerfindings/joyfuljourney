class NotificationService
  class << self
    def create_post_notification(post, type = :post_created)
      return unless post.user.family

      family_members = post.user.family_members
      return if family_members.empty?

      notifications = []
      
      family_members.each do |member|
        notification = Notification.create!(
          user: post.user,
          recipient: member,
          notifiable: post,
          notification_type: Notification::TYPES[type],
          title: notification_title_for_post(post, type),
          message: notification_message_for_post(post, type),
          data: { 
            post_id: post.id,
            user_name: post.user.name,
            family_id: post.user.family_id
          }.to_json
        )
        notifications << notification
      end

      # Also send to family-wide notification
      if post.user.family
        family_notification = Notification.create!(
          user: post.user,
          recipient: post.user.family,
          notifiable: post,
          notification_type: Notification::TYPES[type],
          title: notification_title_for_post(post, type),
          message: notification_message_for_post(post, type),
          data: { 
            post_id: post.id,
            user_name: post.user.name,
            family_id: post.user.family_id
          }.to_json
        )
        notifications << family_notification
      end

      # Send email notifications asynchronously
      notifications.each do |notification|
        next unless notification.recipient.is_a?(User)
        
        NotificationMailer.new_post_notification(notification).deliver_later
      end

      notifications
    end

    def create_milestone_notification(milestone, type = :milestone_created)
      return unless milestone.created_by_user&.family

      family_members = milestone.created_by_user.family_members
      return if family_members.empty?

      notifications = []

      family_members.each do |member|
        notification = Notification.create!(
          user: milestone.created_by_user,
          recipient: member,
          notifiable: milestone,
          notification_type: Notification::TYPES[type],
          title: notification_title_for_milestone(milestone, type),
          message: notification_message_for_milestone(milestone, type),
          data: { 
            milestone_id: milestone.id,
            user_name: milestone.created_by_user.name,
            family_id: milestone.created_by_user.family_id
          }.to_json
        )
        notifications << notification
      end

      # Also create family-wide notification
      if milestone.created_by_user.family
        family_notification = Notification.create!(
          user: milestone.created_by_user,
          recipient: milestone.created_by_user.family,
          notifiable: milestone,
          notification_type: Notification::TYPES[type],
          title: notification_title_for_milestone(milestone, type),
          message: notification_message_for_milestone(milestone, type),
          data: { 
            milestone_id: milestone.id,
            user_name: milestone.created_by_user.name,
            family_id: milestone.created_by_user.family_id
          }.to_json
        )
        notifications << family_notification
      end

      # Send email notifications
      notifications.each do |notification|
        next unless notification.recipient.is_a?(User)
        
        NotificationMailer.new_milestone_notification(notification).deliver_later
      end

      notifications
    end

    def create_reaction_notification(reaction)
      return if reaction.user == reaction.post.user # Don't notify self

      notification = Notification.create!(
        user: reaction.user,
        recipient: reaction.post.user,
        notifiable: reaction.post,
        notification_type: Notification::TYPES[:post_reaction],
        title: "#{reaction.user.name} reacted to your post",
        message: "#{reaction.user.name} reacted with #{reaction.reaction_type} to \"#{reaction.post.title.truncate(50)}\"",
        data: { 
          reaction_id: reaction.id,
          post_id: reaction.post.id,
          user_name: reaction.user.name,
          reaction_type: reaction.reaction_type
        }.to_json
      )

      # Send email notification
      NotificationMailer.new_reaction_notification(notification).deliver_later

      notification
    end

    def create_tagging_notification(taggable_object, tagged_users)
      return if tagged_users.empty?

      notifications = []

      tagged_users.each do |tagged_user|
        # Don't notify the creator
        next if taggable_object.respond_to?(:user) && taggable_object.user == tagged_user
        next if taggable_object.respond_to?(:created_by_user) && taggable_object.created_by_user == tagged_user

        notification = Notification.create!(
          user: taggable_object.respond_to?(:user) ? taggable_object.user : taggable_object.created_by_user,
          recipient: tagged_user,
          notifiable: taggable_object,
          notification_type: Notification::TYPES[:user_tagged],
          title: notification_title_for_tagging(taggable_object, tagged_user),
          message: notification_message_for_tagging(taggable_object, tagged_user),
          data: build_tagging_data(taggable_object, tagged_user)
        )
        notifications << notification

        # Send email notification
        NotificationMailer.user_tagged_notification(notification).deliver_later
      end

      notifications
    end

    def create_family_join_notification(user, family)
      existing_members = family.users.where.not(id: user.id)
      return if existing_members.empty?

      notifications = []

      existing_members.each do |member|
        notification = Notification.create!(
          user: user,
          recipient: member,
          notifiable: family,
          notification_type: Notification::TYPES[:family_joined],
          title: "#{user.name} joined your family",
          message: "#{user.name} has joined the #{family.name} family",
          data: { 
            user_id: user.id,
            user_name: user.name,
            family_id: family.id,
            family_name: family.name
          }.to_json
        )
        notifications << notification

        # Send email notification
        NotificationMailer.family_join_notification(notification).deliver_later
      end

      notifications
    end

    def create_birthday_reminder(user)
      return unless user.family

      family_members = user.family_members
      return if family_members.empty?

      notifications = []

      family_members.each do |member|
        notification = Notification.create!(
          user: user,
          recipient: member,
          notifiable: user,
          notification_type: Notification::TYPES[:birthday_reminder],
          title: "#{user.name}'s birthday is today!",
          message: "Don't forget to wish #{user.name} a happy birthday today!",
          data: { 
            birthday_user_id: user.id,
            birthday_user_name: user.name,
            age: user.age
          }.to_json
        )
        notifications << notification
      end

      notifications
    end

    private

    def notification_title_for_post(post, type)
      case type
      when :post_created
        "New post from #{post.user.name}"
      when :post_updated
        "#{post.user.name} updated a post"
      else
        "Post notification"
      end
    end

    def notification_message_for_post(post, type)
      case type
      when :post_created
        "#{post.user.name} shared a new memory: \"#{post.title.truncate(50)}\""
      when :post_updated
        "#{post.user.name} updated their post \"#{post.title.truncate(50)}\""
      else
        "New activity on a post"
      end
    end

    def notification_title_for_milestone(milestone, type)
      case type
      when :milestone_created
        "New milestone from #{milestone.created_by_user.name}"
      when :milestone_updated
        "#{milestone.created_by_user.name} updated a milestone"
      else
        "Milestone notification"
      end
    end

    def notification_message_for_milestone(milestone, type)
      case type
      when :milestone_created
        "#{milestone.created_by_user.name} reached a new milestone: \"#{milestone.title.truncate(50)}\""
      when :milestone_updated
        "#{milestone.created_by_user.name} updated milestone \"#{milestone.title.truncate(50)}\""
      else
        "New milestone activity"
      end
    end

    def notification_title_for_tagging(taggable_object, tagged_user)
      creator = taggable_object.respond_to?(:user) ? taggable_object.user : taggable_object.created_by_user
      object_type = taggable_object.class.name.downcase
      
      "You were tagged by #{creator.name}"
    end

    def notification_message_for_tagging(taggable_object, tagged_user)
      creator = taggable_object.respond_to?(:user) ? taggable_object.user : taggable_object.created_by_user
      object_type = taggable_object.class.name.downcase
      title = taggable_object.respond_to?(:title) ? taggable_object.title : "#{object_type} ##{taggable_object.id}"
      
      "#{creator.name} tagged you in #{object_type.article} #{object_type}: \"#{title.truncate(50)}\""
    end

    def build_tagging_data(taggable_object, tagged_user)
      creator = taggable_object.respond_to?(:user) ? taggable_object.user : taggable_object.created_by_user
      
      {
        taggable_type: taggable_object.class.name,
        taggable_id: taggable_object.id,
        tagged_user_id: tagged_user.id,
        tagged_user_name: tagged_user.name,
        creator_id: creator.id,
        creator_name: creator.name
      }.to_json
    end
  end
end

# Add article method to String class if not already present
class String
  def article
    %w[a e i o u].include?(self[0].downcase) ? "an" : "a"
  end unless method_defined?(:article)
end