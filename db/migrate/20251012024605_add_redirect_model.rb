class AddRedirectModel < ActiveRecord::Migration[8.0]
  def change
    create_table :redirects do |t|
      t.string :slug, null: false
      t.string :target_url, null: false
      t.timestamps
    end
    add_index :redirects, :slug, unique: true
  end
end
