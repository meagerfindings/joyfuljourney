class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions do |t|
      t.string :reaction_type, null: false
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :reactions, [:post_id, :reaction_type] unless index_exists?(:reactions, [:post_id, :reaction_type])
    add_index :reactions, [:user_id, :post_id], unique: true unless index_exists?(:reactions, [:user_id, :post_id])
    add_index :reactions, :user_id unless index_exists?(:reactions, :user_id)
  end
end