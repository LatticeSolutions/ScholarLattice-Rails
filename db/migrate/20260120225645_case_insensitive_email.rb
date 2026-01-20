class CaseInsensitiveEmail < ActiveRecord::Migration[8.0]
  def change
    enable_extension :citext
    change_column :users, :email, :citext
  end
end
