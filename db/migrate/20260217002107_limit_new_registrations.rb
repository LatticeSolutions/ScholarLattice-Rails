class LimitNewRegistrations < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :limit_one_registration_option, :boolean, default: false, null: false
    add_column :registration_options, :limit_one_per_registration, :boolean, default: false, null: false
  end
end
