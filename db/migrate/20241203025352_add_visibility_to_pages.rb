class AddVisibilityToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :visibility, :integer, default: 2
  end
end
