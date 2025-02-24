class OrderModels < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :order, :integer
    add_column :pages, :order, :integer
  end
end
