class UsePaypalLink < ActiveRecord::Migration[8.0]
  def change
    rename_column :collections, :paypalme_username, :paypal_link
  end
end
