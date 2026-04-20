class ContentForCollectionsAndEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :content, :text
    add_column :events, :content, :text
  end
end
