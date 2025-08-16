class RegOptionAutoAccept < ActiveRecord::Migration[8.0]
  def change
    # Add a new column to the registration options table
    add_column :registration_options, :auto_accept, :boolean, default: false, null: false
  end
end
