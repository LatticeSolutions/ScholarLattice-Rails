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

  def reminder_email_body(sender_name)
    <<~TEXT
        Greetings,

        This is a reminder that you have been invited to submit to #{collection.title} on ScholarLattice.org.
        You can respond to this invitation and submit your abstract by visiting the following link:

        #{Rails.application.routes.url_helpers.invitation_url(self)}

        Thank you for considering our invitation!
        - #{sender_name}
      TEXT
  end
end
