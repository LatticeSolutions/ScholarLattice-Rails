# frozen_string_literal: true

class MenuToggleComponent < ViewComponent::Base
  def initialize(menu_text, menu_icon, button, *links)
    @menu_id = "toggle-menu-#{SecureRandom.hex(8)}"
    @menu_text = menu_text
    @menu_icon = menu_icon
    @button = button
    @links = links
    @links.each { |l| l[:method] = :get if l[:method].nil? }
  end
end
