class AddColorToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :theme_color, :string
  end
end
