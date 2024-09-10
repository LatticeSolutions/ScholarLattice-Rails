# frozen_string_literal: true

class AdminBarComponent < ViewComponent::Base
  def initialize(*links)
    @links = links
  end
end
