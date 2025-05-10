class CreateRegistrationOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :registration_options, id: :uuid do |t|
      t.string :name
      t.integer :cost
      t.datetime :opens_on
      t.datetime :closes_on
      t.integer :stock
      t.references :collection, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    create_table :registrations, id: :uuid do |t|
      t.integer :status, null: false, default: 0
      t.references :registration_option, null: false, foreign_key: true, type: :uuid
      t.references :profile, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    create_table :registration_payments, id: :uuid do |t|
      t.integer :amount, null: false, default: 0
      t.text :memo
      t.references :registration, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
