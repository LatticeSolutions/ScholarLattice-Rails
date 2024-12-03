# frozen_string_literal: true

class PagesBarComponent < ViewComponent::Base
  def initialize(pages, public: true)
    @pages = pages
    @public = public
  end
end
