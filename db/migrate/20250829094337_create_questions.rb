class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions, id: :uuid do |t|
      t.string :name
      t.text :prompt
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
