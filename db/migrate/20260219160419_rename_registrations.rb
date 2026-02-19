class RenameRegistrations < ActiveRecord::Migration[8.0]
  def change
    rename_table :registrations, :old_registrations
    rename_table :new_registrations, :registrations
    rename_column :registration_option_choices, :new_registration_id, :registration_id
  end
end
