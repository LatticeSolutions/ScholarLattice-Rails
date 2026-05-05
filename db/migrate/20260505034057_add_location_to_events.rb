class AddLocationToEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :location, type: :uuid, null: true
  end
end
