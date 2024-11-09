class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_ancestry
  has_many :admins
  has_many :direct_admin_users, through: :admins, source: :user
  has_many :likes
  has_many :favorite_users, through: :likes, source: :user
  has_many :pages
  has_one :home_page, class_name: "Page"

  def admin_users
    User
      .distinct
      .joins(:admins)
      .where(admins: { collection: path_ids })
  end

  def has_admin?(user)
    !user.nil? and admin_users.exists? user.id
  end

  def collection_name
    return "Collection" unless parent
    parent.subcollection_name
  end

  def submittable?
    !submissions_open_on.nil?
  end

  def submissions_closed?
    return true if !submittable?
    return false if submissions_close_on.nil?
    Time.now < submissions_close_on
  end

  def submissions_open?
    return false if !submittable?
    submissions_open_on < Time.now
  end
end
