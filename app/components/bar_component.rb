# frozen_string_literal: true

class BarComponent < ViewComponent::Base
  def initialize(title, icon, links)
    @title = title
    @icon = icon
    @links = links
  end
end
