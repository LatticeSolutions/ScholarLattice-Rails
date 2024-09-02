class CreateCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :collections, id: :uuid do |t|
      t.text :title
      t.text :short_title
      t.text :description
      t.text :website

      t.timestamps
    end
  end
end
