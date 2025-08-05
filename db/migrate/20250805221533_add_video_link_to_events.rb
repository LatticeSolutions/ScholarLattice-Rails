class AddVideoLinkToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :web_conference_link, :string
  end
end
