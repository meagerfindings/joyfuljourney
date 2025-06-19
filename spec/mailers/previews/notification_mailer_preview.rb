# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_post_notification
  def new_post_notification
    NotificationMailer.new_post_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_milestone_notification
  def new_milestone_notification
    NotificationMailer.new_milestone_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_reaction_notification
  def new_reaction_notification
    NotificationMailer.new_reaction_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/user_tagged_notification
  def user_tagged_notification
    NotificationMailer.user_tagged_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/family_join_notification
  def family_join_notification
    NotificationMailer.family_join_notification
  end

end
