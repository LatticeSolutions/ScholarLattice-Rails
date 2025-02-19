class EventRequiredAttributes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :events, :title, false
    change_column_default :events, :title, "Untitled Event"
  end
end
