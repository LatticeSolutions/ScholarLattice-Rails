class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :affiliation, presence: true
  validates :position, presence: true
  validates :position_type, presence: true

  enum :position_type, {
    faculty: 0,
    postdoc: 5,
    grad_student: 1,
    undergrad_student: 2,
    secondary_student: 3,
    staff: 6,
    other: 4
  }

  has_many :admins
  has_many :direct_admin_collections, through: :admins, source: :collection
  has_many :likes, dependent: :destroy
  has_many :favorite_collections, through: :likes, source: :collection

  has_and_belongs_to_many :profiles


  has_many :managed_users_link, foreign_key: :manager_id, class_name: "UserManagement"
  has_many :managed_users, through: :managed_users_link, source: :user

  has_many :managing_users_link, foreign_key: :user_id, class_name: "UserManagement"
  has_many :managing_users, through: :managing_users_link, source: :manager

  has_many :submissions
  has_many :registrations
  has_many :invitations

  before_save :downcase_email
  before_save :strip_whitespace

  default_scope { order(:last_name, :first_name) }

  def description
    if affiliation.present? and position.present?
      "#{position} at #{affiliation}"
    elsif affiliation.present?
      affiliation
    elsif position.present?
      position
    else
      ""
    end
  end

  def self.fetch_resource_for_passwordless(email)
    find_by(email: email)
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

  def name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    "#{name} ⟨#{email}⟩"
  end

  def registered_for?(collection)
    registrations_for(collection).any?
  end

  def registrations_for(collection)
    registrations.where(registration_option: collection.registration_options)
  end

  def main_profile
    profiles.first
  end

  private

  def strip_whitespace
    self.first_name = first_name&.strip
    self.last_name = last_name&.strip
    self.email = email&.strip
    self.affiliation = affiliation&.strip
    self.position = position&.strip
  end
end
