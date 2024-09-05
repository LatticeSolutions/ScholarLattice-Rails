class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  has_many :admins
  has_many :collections, through: :admins

  def self.fetch_resource_for_passwordless(email)
    find_or_create_by(email: email)
  end
end
