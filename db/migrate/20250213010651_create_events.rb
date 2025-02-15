class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events, id: :uuid do |t|
      t.string :title
      t.text :description
      t.string :location
      t.datetime :starts_at
      t.datetime :ends_at
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
