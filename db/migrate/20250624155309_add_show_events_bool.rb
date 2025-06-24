class AddShowEventsBool < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :show_events, :boolean, default: true, null: false
  end
end
