class DeprecateHomePageAttachedPage < ActiveRecord::Migration[8.0]
  def change
    Page.where(is_home: true) do |p|
      p.collection.content = p.content
      p.destroy
    end
    remove_column :pages, :is_home, :boolean
    Event.where.not(attached_page: nil) do |e|
      e.content = e.attached_page.content
      e.attached_page.destroy
    end
    remove_column :events, :attached_page_id, :uuid
  end
end
