# frozen_string_literal: true

class PagesBarComponent < ViewComponent::Base
  def initialize(pages)
    @pages = pages
  end
end
