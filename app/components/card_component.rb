# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  def initialize(title:, description:, link_text:, link_url:)
    @title = title
    @description = description
    @link_text = link_text
    @link_url = link_url
  end
end
