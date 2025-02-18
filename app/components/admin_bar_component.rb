# frozen_string_literal: true

class AdminBarComponent < ViewComponent::Base
  def initialize(*links)
    @links = links
    @links.map! { |l| l[:color] = "purple-800" unless l[:color]; l }
  end
end
