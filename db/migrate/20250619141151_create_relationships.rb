class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :related_user, null: false, foreign_key: { to_table: :users }
      t.string :relationship_type, null: false

      t.timestamps
    end

    add_index :relationships, [:user_id, :related_user_id], unique: true
    add_index :relationships, :relationship_type
  end
end
