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
  has_and_belongs_to_many :profiles

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
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
      Submission.where profile: profiles
    else
      Submission.where profile: profiles, collection: collection
    end
  end
end
