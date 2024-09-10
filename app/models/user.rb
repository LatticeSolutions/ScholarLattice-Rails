class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  has_many :admins
  has_many :direct_admin_collections, through: :admins, source: :collection

  def self.fetch_resource_for_passwordless(email)
    find_or_create_by(email: email)
  end

  def gravatar(kwargs = { size: 50, rating: "g", def: "identicon" })
    "//en.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{kwargs[:size]}&r=#{kwargs[:rating]}&d=#{kwargs[:def]}"
  end

  def can_administrate?(collection)
    site_admin or collection.has_admin? self
  end
end
