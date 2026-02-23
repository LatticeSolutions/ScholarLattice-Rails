class AddInfoPrompt < ActiveRecord::Migration[8.0]
  def change
    add_column :registration_options, :info_prompt, :string
  end
end
