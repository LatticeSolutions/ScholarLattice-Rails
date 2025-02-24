class OrderedEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :order, :integer
  end
end
