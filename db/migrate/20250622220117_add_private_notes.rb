class AddPrivateNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :private_notes, :string
  end
end
