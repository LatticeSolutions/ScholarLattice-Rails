class Registration < ApplicationRecord
  belongs_to :registration_option
  has_many :registration_payments, dependent: :destroy
  belongs_to :user
  has_one :collection, through: :registration_option
  enum :status, { submitted: 0, accepted: 1, declined: 2 }

  has_many :questions, through: :collection

  validate :user_domain_allowed?
  validates :user, uniqueness: { scope: :registration_option_id, message: "has already registered using this option" }

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
      user.last_name,
      user.first_name,
      user.email,
      user.affiliation,
      user.position,
      user.position_type
    ]
  end

  def self.to_csv
    require "csv"
    attributes = %w[id registration_option status collection_id collection user_last_name user_first_name user_email user_affiliation user_position user_position_type]
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |submission|
        csv << submission.csv_row
      end
    end
  end

  private

  def user_domain_allowed?
    unless registration_option.allowed_domains_array.nil? || registration_option.allowed_domains_array.include?(user.email.split("@").last)
      errors.add(:user, "email domain is not allowed for this registration option")
    end
  end
end
