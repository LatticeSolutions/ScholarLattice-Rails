class CreateQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :queries, id: :uuid do |t|
      t.references :registration_option, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :queries, [ :registration_option_id, :question_id ], unique: true
  end
end
