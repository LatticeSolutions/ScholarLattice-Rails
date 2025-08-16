class Registration < ApplicationRecord
  belongs_to :registration_option
  has_many :registration_payments, dependent: :destroy
  belongs_to :profile
  has_one :collection, through: :registration_option
  enum :status, { submitted: 0, accepted: 1, declined: 2 }

  validate :profile_domain_allowed?
  validates :profile, uniqueness: { scope: :registration_option_id, message: "has already registered using this option" }

  def payment_total
    registration_payments.sum(:amount)
  end

  def csv_row
    [
      id,
      registration_option.name,
      status.humanize,
      collection.id,
      collection.short_title_path,
      profile.last_name,
      profile.first_name,
      profile.email,
      profile.affiliation,
      profile.position,
      profile.position_type
    ]
  end

  def self.to_csv
    require "csv"
    attributes = %w[id registration_option status collection_id collection profile_last_name profile_first_name profile_email profile_affiliation profile_position profile_position_type]
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |submission|
        csv << submission.csv_row
      end
    end
  end

  private

  def profile_domain_allowed?
    unless registration_option.allowed_domains_array.nil? || registration_option.allowed_domains_array.include?(profile.email.split("@").last)
      errors.add(:profile, "email domain is not allowed for this registration option")
    end
  end
end
