class Page < ApplicationRecord
  belongs_to :collection

  def content_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render content
  end
end
