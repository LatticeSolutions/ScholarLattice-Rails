class RestrictDomains < ActiveRecord::Migration[8.0]
  def change
    add_column :registration_options, :allowed_domains, :string
  end
end
