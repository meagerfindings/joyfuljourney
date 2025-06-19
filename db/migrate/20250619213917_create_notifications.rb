class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true, comment: 'User who triggered the notification'
      t.references :recipient, polymorphic: true, null: false, comment: 'User or group receiving the notification'
      t.references :notifiable, polymorphic: true, null: false, comment: 'The object that triggered the notification'
      t.string :notification_type, null: false, comment: 'Type of notification (post_created, milestone_reached, etc.)'
      t.string :title, null: false
      t.text :message
      t.datetime :read_at, comment: 'When the notification was read'
      t.datetime :email_sent_at, comment: 'When email notification was sent'
      t.text :data, comment: 'Additional JSON data for the notification'

      t.timestamps
    end

    add_index :notifications, [:recipient_type, :recipient_id], name: 'idx_notifications_recipient'
    add_index :notifications, [:notifiable_type, :notifiable_id], name: 'idx_notifications_notifiable'
    add_index :notifications, :notification_type, name: 'idx_notifications_type'
    add_index :notifications, :read_at, name: 'idx_notifications_read_at'
    add_index :notifications, :created_at, name: 'idx_notifications_created_at'
    add_index :notifications, [:recipient_type, :recipient_id, :read_at], name: 'idx_notifications_recipient_read'
  end
end
