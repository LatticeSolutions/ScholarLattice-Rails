class CreateRegistrationOptionChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :registration_option_choices, id: :uuid do |t|
      t.references :new_registration, null: false, foreign_key: true, type: :uuid
      t.references :registration_option, null: false, foreign_key: true, type: :uuid
      t.integer :amount
      t.string :info

      t.timestamps
    end
    add_index :registration_option_choices, [ :new_registration_id, :registration_option_id ], unique: true
  end
end
