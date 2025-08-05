class AddPageCollectionToEvent < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :attached_page, type: :uuid, null: true, index: { unique: true }, foreign_key: { to_table: :pages }
    add_reference :events, :attached_collection, type: :uuid, null: true, index: { unique: true }, foreign_key: { to_table: :collections }
  end
end
