class DropProfileTable < ActiveRecord::Migration[8.0]
  def up
    remove_column :old_registrations, :profile_id, :uuid
    remove_column :submissions, :profile_id, :uuid
    remove_column :invitations, :profile_id, :uuid
    drop_table :profiles_users
    drop_table :profiles
  end
end
