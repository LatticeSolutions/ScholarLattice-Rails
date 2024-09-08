class AddCollectionSubcollectionName < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :subcollection_name, :string, null: false, default: "Subcollection"
  end
end
