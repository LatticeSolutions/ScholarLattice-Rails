class AddIsHomeToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :is_home, :boolean, default: :false
  end
end
