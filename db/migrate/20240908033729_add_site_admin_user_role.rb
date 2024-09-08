class AddSiteAdminUserRole < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :site_admin, :boolean, null: false, default: false
  end
end
