class AddAncestryToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :ancestry, :string, collation: "C", default: "/", null: false
    add_index :collections, :ancestry
  end
end
