class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.belongs_to :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
