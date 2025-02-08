class Submission < ApplicationRecord
  belongs_to :profile
  belongs_to :collection
  enum :status, { submitted: 0, accepted: 1, declined: 2, draft: 3 }

  def abstract_html
    Kramdown::Document.new(abstract).to_html
  end

  def has_admin?(user)
    user.profiles.include? profile or
    collection.has_admin? user or
    user.site_admin
  end

  def notification_emails
    [
      profile.email,
      *collection.admins.map(&:user).map(&:email)
    ].uniq
  end
end
