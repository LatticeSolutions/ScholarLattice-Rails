class CreateAdmins < ActiveRecord::Migration[7.2]
  def change
    create_table :admins, id: :uuid do |t|
      t.belongs_to :collection, type: :uuid
      t.belongs_to :user, type: :uuid
      t.timestamps
    end
  end
end
