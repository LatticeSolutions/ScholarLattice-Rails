class AddSubmissionsOpenToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :submissions_open_on, :datetime
    add_column :collections, :submissions_close_on, :datetime
  end
end
