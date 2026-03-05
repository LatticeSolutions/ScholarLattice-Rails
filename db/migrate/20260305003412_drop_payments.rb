class DropPayments < ActiveRecord::Migration[8.0]
  def up
    drop_table :registration_payments
  end
end
