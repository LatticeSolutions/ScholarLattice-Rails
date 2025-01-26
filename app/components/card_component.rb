# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  def initialize(title:, description:, link_text:, link_url:, title_icon:, crumbs:)
    @title = title
    @description = description
    @link_text = link_text
    @link_url = link_url
    @title_icon = title_icon
    @crumbs = crumbs
  end
end
