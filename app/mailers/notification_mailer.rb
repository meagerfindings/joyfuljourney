class NotificationMailer < ApplicationMailer
  default from: 'notifications@joyfuljourney.com'

  def new_post_notification(notification)
    @notification = notification
    @recipient = notification.recipient
    @post = notification.notifiable
    @user = notification.user

    return unless @recipient.is_a?(User) && @recipient.username.present?

    mail(
      to: "#{@recipient.name} <#{@recipient.username}@example.com>",
      subject: "New post from #{@user.name} - Joyful Journey"
    ) do |format|
      format.html { render }
      format.text { render }
    end

    @notification.mark_email_as_sent!
  end

  def new_milestone_notification(notification)
    @notification = notification
    @recipient = notification.recipient
    @milestone = notification.notifiable
    @user = notification.user

    return unless @recipient.is_a?(User) && @recipient.username.present?

    mail(
      to: "#{@recipient.name} <#{@recipient.username}@example.com>",
      subject: "New milestone from #{@user.name} - Joyful Journey"
    ) do |format|
      format.html { render }
      format.text { render }
    end

    @notification.mark_email_as_sent!
  end

  def new_reaction_notification(notification)
    @notification = notification
    @recipient = notification.recipient
    @post = notification.notifiable
    @user = notification.user
    @reaction_type = notification.data_hash['reaction_type']

    return unless @recipient.is_a?(User) && @recipient.username.present?

    mail(
      to: "#{@recipient.name} <#{@recipient.username}@example.com>",
      subject: "#{@user.name} reacted to your post - Joyful Journey"
    ) do |format|
      format.html { render }
      format.text { render }
    end

    @notification.mark_email_as_sent!
  end

  def user_tagged_notification(notification)
    @notification = notification
    @recipient = notification.recipient
    @taggable = notification.notifiable
    @user = notification.user

    return unless @recipient.is_a?(User) && @recipient.username.present?

    object_type = @taggable.class.name.downcase
    
    mail(
      to: "#{@recipient.name} <#{@recipient.username}@example.com>",
      subject: "You were tagged by #{@user.name} - Joyful Journey"
    ) do |format|
      format.html { render }
      format.text { render }
    end

    @notification.mark_email_as_sent!
  end

  def family_join_notification(notification)
    @notification = notification
    @recipient = notification.recipient
    @family = notification.notifiable
    @user = notification.user

    return unless @recipient.is_a?(User) && @recipient.username.present?

    mail(
      to: "#{@recipient.name} <#{@recipient.username}@example.com>",
      subject: "#{@user.name} joined your family - Joyful Journey"
    ) do |format|
      format.html { render }
      format.text { render }
    end

    @notification.mark_email_as_sent!
  end
end
