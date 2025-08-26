class NoSillyUserDefaults < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :first_name, from: 'FirstName', to: nil
    change_column_default :users, :last_name, from: 'LastName', to: nil
    change_column_default :users, :affiliation, from: 'Unaffiliated', to: nil
    change_column_default :users, :position, from: 'None', to: nil
    change_column_default :users, :position_type, from: 4, to: nil
  end
end
