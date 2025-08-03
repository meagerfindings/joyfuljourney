class CreateMilestones < ActiveRecord::Migration[7.0]
  def change
    create_table :milestones do |t|
      t.string :title, null: false
      t.text :description
      t.date :milestone_date, null: false
      t.string :milestone_type, null: false
      t.references :milestoneable, polymorphic: true, null: false
      t.bigint :created_by_user_id, null: false
      t.boolean :is_private, default: false, null: false

      t.timestamps
    end

    add_index :milestones, [:milestoneable_type, :milestoneable_id]
    add_index :milestones, :milestone_date
    add_index :milestones, :milestone_type
    add_foreign_key :milestones, :users, column: :created_by_user_id
  end
end
