class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  enum :status, { pending: 0, accepted: 1, declined: 2, revoked: 3 }

  def message_html
    Kramdown::Document.new(message).to_html
  end

  def submissions
    user.submissions.where(collection: collection)
  end

  def submitted?
    submissions.any?
  end

  def notification_emails
    [
      user.email,
      *collection.admins.map(&:user).map(&:email)
    ].uniq
  end
end
