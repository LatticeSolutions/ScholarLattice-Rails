class Invitation < ApplicationRecord
  belongs_to :profile
  belongs_to :collection
  enum :status, { pending: 0, accepted: 1, declined: 2, revoked: 3 }

  def message_html
    Kramdown::Document.new(message).to_html
  end
end
