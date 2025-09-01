class AddAffiliationIdToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :affiliation_identifier, :string
  end
end
