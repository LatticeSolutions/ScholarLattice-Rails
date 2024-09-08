class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_ancestry
  has_many :admins
  has_many :admin_users, through: :admins, source: :user

  def has_admin?(user)
    user.site_admin or admin_users.include?(user) or ancestors.where(admin_users: user).exists?
  end
end
