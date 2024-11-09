class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions, id: :uuid do |t|
      t.string :title
      t.text :abstract
      t.text :notes
      t.references :profile, null: false, foreign_key: true, type: :uuid
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
