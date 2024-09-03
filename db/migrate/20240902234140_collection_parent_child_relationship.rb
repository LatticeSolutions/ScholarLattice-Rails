class CollectionParentChildRelationship < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :parent_id, :string
  end
end
