class AddTimeZone < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :time_zone, :string
  end
end
