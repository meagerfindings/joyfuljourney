class CreateFamilyInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :family_invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.references :family, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at, null: false
      t.integer :status, default: 0, null: false
      t.text :message

      t.timestamps
    end
    
    add_index :family_invitations, :email
    add_index :family_invitations, :token, unique: true
    add_index :family_invitations, [:email, :family_id], unique: true
  end
end
