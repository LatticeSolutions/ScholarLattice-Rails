class StaticPagesController < ApplicationController
  def privacy
    markdown = File.read("#{Rails.root}/site/PRIVACY.md")
    @html = Kramdown::Document.new(markdown).to_html
  end

  def tos
    markdown = File.read("#{Rails.root}/site/TOS.md")
    @html = Kramdown::Document.new(markdown).to_html
  end
end
