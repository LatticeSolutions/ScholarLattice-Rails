class AddPaypalmeLink < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :paypalme_username, :string
  end
end
