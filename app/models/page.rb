class Page < ApplicationRecord
  belongs_to :collection

  def content_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render content
  end

  def is_home_page?
    collection.home_page == self
  end
end
