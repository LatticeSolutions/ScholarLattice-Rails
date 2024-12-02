class AddPositionToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :position_type, :integer, default: 0
  end
end
