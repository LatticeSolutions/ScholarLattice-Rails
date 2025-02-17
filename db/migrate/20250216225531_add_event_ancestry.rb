class AddEventAncestry < ActiveRecord::Migration[8.0]
  def change
    change_table(:events) do |t|
      # postgres
      t.string "ancestry", default: "/", collation: 'C', null: false
      t.index "ancestry"
      t.references :submission, null: true, foreign_key: true, type: :uuid
    end
  end
end
