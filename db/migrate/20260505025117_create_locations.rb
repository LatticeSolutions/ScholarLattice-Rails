class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    rename_column :events, :location, :location_string
    create_table :locations, id: :uuid do |t|
      t.string :title
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
