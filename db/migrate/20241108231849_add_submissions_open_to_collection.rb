class AddSubmissionsOpenToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :submissions_open_on, :timestamptz
    add_column :collections, :submissions_close_on, :timestamptz
  end
end
