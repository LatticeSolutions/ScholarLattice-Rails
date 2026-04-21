class DeprecateHomePageAttachedPage < ActiveRecord::Migration[8.0]
  def change
    remove_column :pages, :is_home, :boolean
    remove_column :events, :attached_page_id, :uuid
  end
end
