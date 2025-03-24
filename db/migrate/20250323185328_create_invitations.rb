class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :profile, null: false, foreign_key: true, type: :uuid
      t.references :collection, null: false, foreign_key: true, type: :uuid
      t.integer :status, null: false, default: 0
      t.text :message

      t.timestamps
    end
  end
end
