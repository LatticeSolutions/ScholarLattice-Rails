class CreatePages < ActiveRecord::Migration[7.2]
  def change
    create_table :pages, id: :uuid do |t|
      t.string :title, null: false, default: "New Page"
      t.text :content, null: false, default: "Page content goes here."
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_reference :collections, :page, type: :uuid, null: true
  end
end
