class CollectionRegisterable < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :registerable, :boolean, null: false, default: false
  end
end
