class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_ancestry
  has_many :admins
  has_many :direct_admin_users, through: :admins, source: :user
  has_many :pages
  has_one :home_page, class_name: "Page"

  def admin_users
    User
      .distinct
      .joins(:admins)
      .where(admins: { collection: path_ids })
  end

  def has_admin?(user)
    admin_users.include?(user)
  end

  def collection_name
    return "Collection" unless parent
    parent.subcollection_name
  end
end
