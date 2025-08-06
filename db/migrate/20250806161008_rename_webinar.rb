class RenameWebinar < ActiveRecord::Migration[8.0]
  def change
    rename_column :events, :web_conference_link, :webinar_link
  end
end
