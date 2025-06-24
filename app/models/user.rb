class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  has_many :admins
  has_many :direct_admin_collections, through: :admins, source: :collection
  has_many :likes, dependent: :destroy
  has_many :favorite_collections, through: :likes, source: :collection

  before_save :downcase_email

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def managed_users
    (UserManager.where(manager: self).map(&:user) + [ self ]).uniq
  end

  def self.fetch_resource_for_passwordless(email)
    find_or_create_by(email: email)
  end

  def admin_collections
    return Collection.all if site_admin
    direct_admin_collections.map(&:subtree).flatten.uniq
  end

  def gravatar(kwargs = { size: 50, rating: "g", def: "identicon" })
    "//en.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{kwargs[:size]}&r=#{kwargs[:rating]}&d=#{kwargs[:def]}"
  end

  def can_administrate?(collection)
    site_admin or collection.has_admin? self
  end

  def likes?(collection)
    !Like.where(user: self, collection: collection).empty?
  end

  def submissions(collection = nil)
    if collection.nil?
      Submission.where user: managed_users
    else
      Submission.where user: managed_users, collection: collection
    end
  end

  def invitations
    Invitation.where user: managed_users
  end

  def registrations
    Registration.where user: managed_users
  end
end
