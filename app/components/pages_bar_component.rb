# frozen_string_literal: true

class PagesBarComponent < ViewComponent::Base
  def initialize(page_links)
    @page_links = page_links.reject { |l| l[:hidden] }
  end
end
