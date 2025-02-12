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

  def csv_row
    [ id, profile.last_name, profile.first_name, profile.email, title, abstract, notes, status.humanize ]
  end

  def self.to_csv
    require "csv"
    attributes = %w[id profile_last_name profile_first_name profile_email title abstract notes status] # customize columns here
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |submission|
        csv << submission.csv_row
      end
    end
  end
end
