class CollectionsCanHavePublicWebinars < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :public_webinars, :boolean, default: false, null: false
  end
end
