class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_ancestry
  has_many :admins
  has_many :admin_users, through: :admins, source: :user

  def has_admin?(user)
    return false if !user
    user.site_admin or admin_users.include?(user) or Admin.where(user: user, collection: ancestors).exists?
  end

  def collection_name
    return "Collection" unless parent
    parent.subcollection_name
  end
end
