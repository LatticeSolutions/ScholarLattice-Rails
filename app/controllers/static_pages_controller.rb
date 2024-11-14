class StaticPagesController < ApplicationController
  def privacy
    markdown = File.read("#{Rails.root}/site/PRIVACY.md")
    @html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render markdown
  end

  def tos
    markdown = File.read("#{Rails.root}/site/TOS.md")
    @html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render markdown
  end
end
