class AffiliationIdentifierAlias < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :affiliation_identifier_alias, :string
  end
end
