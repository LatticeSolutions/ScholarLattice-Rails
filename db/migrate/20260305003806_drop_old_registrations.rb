class DropOldRegistrations < ActiveRecord::Migration[8.0]
  def up
    drop_table :old_registrations
  end
end
