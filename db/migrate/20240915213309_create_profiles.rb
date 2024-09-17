class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :affiliation
      t.string :position

      t.timestamps
    end
    add_index :profiles, [ :user_id, :email ], unique: true
  end
end
