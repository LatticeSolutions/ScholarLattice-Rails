class AddImageUrlsToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :icon_url, :string
    add_column :collections, :banner_url, :string
  end
end
