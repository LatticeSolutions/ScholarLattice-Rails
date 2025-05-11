class AddExternalIdToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :registration_payments, :external_id, :string
  end
end
