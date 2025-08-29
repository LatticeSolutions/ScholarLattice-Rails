class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers, id: :uuid do |t|
      t.text :response
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :answers, [ :question_id, :user_id ], unique: true
  end
end
