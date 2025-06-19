class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true, comment: 'User who performed the activity'
      t.references :trackable, polymorphic: true, null: false, comment: 'The object being tracked'
      t.string :activity_type, null: false, comment: 'Type of activity (created, updated, reacted, etc.)'
      t.text :data, comment: 'Additional JSON data for the activity'
      t.datetime :occurred_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }, comment: 'When the activity occurred'

      t.timestamps
    end

    add_index :activities, [:trackable_type, :trackable_id], name: 'idx_activities_trackable'
    add_index :activities, :activity_type, name: 'idx_activities_type'
    add_index :activities, :occurred_at, name: 'idx_activities_occurred_at'
    add_index :activities, [:user_id, :occurred_at], name: 'idx_activities_user_time'
    add_index :activities, [:trackable_type, :trackable_id, :occurred_at], name: 'idx_activities_trackable_time'
  end
end
