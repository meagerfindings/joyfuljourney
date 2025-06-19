class NotificationsController < ApplicationController
  before_action :require_login
  before_action :set_notification, only: [:show, :mark_as_read]

  def index
    @notifications = current_user.notifications.recent.includes(:user, :notifiable)
    @unread_count = current_user.unread_notifications_count
    
    # Paginate notifications
    @notifications = @notifications.limit(50)
    
    # Separate unread and read
    @unread_notifications = @notifications.unread
    @read_notifications = @notifications.read.limit(20)
  end

  def show
    @notification.mark_as_read! if @notification.unread?
    
    # Redirect to the related object
    redirect_to @notification.path || root_path
  end

  def mark_as_read
    if @notification.mark_as_read!
      respond_to do |format|
        format.html { redirect_back(fallback_location: notifications_path) }
        format.json { render json: { status: 'success', message: 'Notification marked as read' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: notifications_path, alert: 'Could not mark notification as read') }
        format.json { render json: { status: 'error', message: 'Could not mark notification as read' } }
      end
    end
  end

  def mark_all_as_read
    count = current_user.mark_all_notifications_as_read!
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Marked #{count} notifications as read" }
      format.json { render json: { status: 'success', message: "Marked #{count} notifications as read", count: count } }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path, alert: 'Notification not found'
  end
end
