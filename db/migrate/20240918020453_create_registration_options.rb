class CreateRegistrationOptions < ActiveRecord::Migration[7.2]
  def change
    create_table :registration_options, id: :uuid do |t|
      t.references :collection, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.string :description
      t.datetime :opens_at
      t.datetime :closes_at

      t.timestamps
    end
  end
end
