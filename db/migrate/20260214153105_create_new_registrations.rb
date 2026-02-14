class CreateNewRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :new_registrations, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :new_registrations, [ :user_id, :collection_id ], unique: true
  end
end
