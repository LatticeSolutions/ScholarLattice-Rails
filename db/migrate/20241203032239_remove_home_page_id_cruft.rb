class RemoveHomePageIdCruft < ActiveRecord::Migration[8.0]
  def change
    remove_column :collections, :home_page_id
  end
end
