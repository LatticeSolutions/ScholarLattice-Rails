class RemovePageId < ActiveRecord::Migration[8.0]
  def change
    remove_column :collections, :page_id
  end
end
