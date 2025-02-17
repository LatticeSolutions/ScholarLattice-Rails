class Event < ApplicationRecord
  belongs_to :collection

  def description_html
    Kramdown::Document.new(description).to_html
  end
end
