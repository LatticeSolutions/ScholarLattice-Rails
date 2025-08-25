class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  has_one :event, required: false
  enum :status, { submitted: 0, accepted: 1, declined: 2, draft: 3 }

  default_scope { order(:title) }

  def abstract_html
    Kramdown::Document.new(abstract).to_html
  end

  def notes_html
    Kramdown::Document.new(notes).to_html
  end

  def private_notes_html
    Kramdown::Document.new(private_notes).to_html
  end

  def invited?
    collection.invitations.where(user: user).any?
  end

  def has_admin?(user)
    user.id == @user.id or
    collection.has_admin? user or
    user.site_admin
  end

  def notification_emails
    [
      user.email,
      *collection.admins.map(&:user).map(&:email)
    ].uniq
  end

  def csv_row
    [ id, collection.id, collection.short_title_path, user.last_name, user.first_name, user.email, title, abstract, notes, status.humanize ]
  end

  def self.to_csv
    require "csv"
    attributes = %w[id collection_id collection user_last_name user_first_name user_email title abstract notes status]
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |submission|
        csv << submission.csv_row
      end
    end
  end
end
