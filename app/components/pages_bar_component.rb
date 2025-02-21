# frozen_string_literal: true

class PagesBarComponent < ViewComponent::Base
  def initialize(pages, public: true, label: "Pages")
    @pages = pages
    @public = public
    @label = label
  end
end
