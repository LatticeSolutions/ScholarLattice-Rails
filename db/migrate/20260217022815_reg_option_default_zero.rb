class RegOptionDefaultZero < ActiveRecord::Migration[8.0]
  def change
    change_column_default :registration_option_choices, :amount, from: nil, to: 0
  end
end
